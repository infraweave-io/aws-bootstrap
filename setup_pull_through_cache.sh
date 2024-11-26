#!/bin/bash

# Configure the following variables to match your environment

aws_profiles=("central" "project1-dev" "project1-prod" "project2-dev")
regions=("eu-central-1" "us-west-2")


# No need to modify below this line

images=("runner:arm64" "reconciler-aws:arm64")
ecr_repository_prefix="infraweave"
upstream_registry_url="quay.io"

for aws_profile in "${aws_profiles[@]}"; do
    account_id=$(aws --profile $aws_profile sts get-caller-identity --query "Account" --output text)

    for region in "${regions[@]}"; do
        echo
        echo "== Setting up pull-through cache in region: $region for account: $account_id =="
        aws --profile $aws_profile ecr create-pull-through-cache-rule --region $region --ecr-repository-prefix $ecr_repository_prefix --upstream-registry-url $upstream_registry_url > /dev/null 2>&1 || echo "    Rule may already exist, skipping."
        aws --profile $aws_profile ecr get-login-password --region $region | docker login --username AWS --password-stdin $account_id.dkr.ecr.$region.amazonaws.com  > /dev/null 2>&1
        echo "  Pulling images from upstream registry: $upstream_registry_url\n"
        for image in "${images[@]}"; do
            echo
            docker pull $account_id.dkr.ecr.$region.amazonaws.com/$ecr_repository_prefix/infraweave/$image
        done
        echo
    done
done
