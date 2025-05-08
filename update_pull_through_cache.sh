#!/bin/bash

# Configure the following variables to match your environment

aws_profile_central="central"
regions=("eu-central-1" "us-west-2")

# ============ No need to modify below this line ============

version="v0.0.84"

images=("infraweave/gitops-aws:$version-arm64" "infraweave/runner:$version-arm64" "infraweave/reconciler-aws:$version-arm64")
ecr_repository_prefix="infraweave-ecr-public"
upstream_registry_url="public.ecr.aws"

account_id=$(aws --profile "$aws_profile_central" sts get-caller-identity --query "Account" --output text)

org_id=$(aws --profile "$aws_profile_central" organizations describe-organization --query "Organization.Id" --output text 2>/dev/null)
if [ -z "$org_id" ]; then
    echo "WARNING: Could not determine organization ID. Repository policies will not be set to allow organization-wide pull."
else
    echo "Organization ID detected: $org_id"
fi

for region in "${regions[@]}"; do
    echo
    echo "== Setting up pull-through cache in region: $region for account: $account_id =="
    aws --profile "$aws_profile_central" ecr create-pull-through-cache-rule \
        --region "$region" \
        --ecr-repository-prefix "$ecr_repository_prefix" \
        --upstream-registry-url "$upstream_registry_url" > /dev/null 2>&1 || echo "    Rule may already exist, skipping."

    aws --profile "$aws_profile_central" ecr get-login-password --region "$region" | \
        docker login --username AWS --password-stdin "$account_id.dkr.ecr.$region.amazonaws.com"  > /dev/null 2>&1

    echo "  Pulling images from upstream registry: $upstream_registry_url"
    for image in "${images[@]}"; do
        echo
        docker pull "$account_id.dkr.ecr.$region.amazonaws.com/$ecr_repository_prefix/$image"
    done

    # If organization id is available, set repository policy on each repository
    if [ -n "$org_id" ]; then
        for image in "${images[@]}"; do
            # Extract the repository name (without the tag)
            repo=$(echo "$image" | cut -d: -f1)
            full_repo="$ecr_repository_prefix/$repo"
            echo
            echo "  Setting repository policy for $full_repo in region $region"

            # Build the repository policy JSON
            policy=$(cat <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AllowOrganizationPull",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
         "ecr:BatchGetImage",
         "ecr:GetDownloadUrlForLayer",
         "ecr:BatchCheckLayerAvailability"
      ],
      "Condition": {
         "StringEquals": {
             "aws:PrincipalOrgID": "$org_id"
         }
      }
    },
    {
      "Sid": "AllowECRPull",
      "Effect": "Allow",
      "Principal": "ecr.amazonaws.com",
      "Action": [
         "ecr:BatchGetImage",
         "ecr:GetDownloadUrlForLayer",
         "ecr:BatchCheckLayerAvailability"
      ]
    }
  ]
}
EOF
)
            aws --profile "$aws_profile_central" ecr set-repository-policy \
                --repository-name "$full_repo" \
                --policy-text "$policy" \
                --region "$region" > /dev/null 2>&1
        done
    fi
    echo
done
