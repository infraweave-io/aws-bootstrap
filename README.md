
# AWS Bootstrap for InfraWeave

This repository provides Terraform configurations to bootstrap your AWS accounts for the InfraWeave platform. It sets up the necessary infrastructure in both your central (control plane) account and workload accounts across multiple regions.

## Overview

InfraWeave uses a hub-and-spoke architecture:
- **Central Account**: Hosts the control plane components (webhook processor, API, OIDC provider)
- **Workload Accounts**: Host your application workloads and infrastructure managed by InfraWeave

This bootstrap process configures both account types with the required IAM roles, networking, Lambda functions, and regional resources.

## Prerequisites

Before you begin, ensure you have:

- **AWS CLI** v2.x ([installation guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
- **Terraform** v1.0 or later ([installation guide](https://developer.hashicorp.com/terraform/downloads))
- **AWS SSO configured** with access to your AWS accounts
- **Administrative access** to all AWS accounts (central and workload accounts)
- **Git** installed for cloning the repository

## Getting Started

### 1. Clone the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/infraweave-io/aws-bootstrap.git
cd aws-bootstrap
```

### Repository Structure

```
.
├── LICENSE
├── README.md
├── backend.tf              # Terraform backend configuration (state storage)
├── central.tf              # Central account infrastructure
├── locals.tf               # Configuration variables
├── project1-dev.tf         # Example workload account (duplicate for each project)
└── update_pull_through_cache.sh  # Script to populate ECR pull-through cache
```

### 2. Set Up AWS SSO Configuration 🔧

Configure AWS SSO profiles for all your accounts in `~/.aws/config`:

```ini
# Filename: ~/.aws/config

[profile central]
sso_account_id = 000000000000  # Replace with your central account ID
region = us-east-1
sso_session = aws-sso-session
sso_role_name = AdministratorAccess

[profile project1-dev]
sso_account_id = 111111111111  # Replace with your workload account ID
region = us-east-1
sso_session = aws-sso-session
sso_role_name = AdministratorAccess

[sso-session aws-sso-session]
sso_start_url = https://d-1234567890.awsapps.com/start  # Replace with your SSO URL
sso_region = us-east-1
sso_registration_scopes = sso:account:access
```

**Note**: Replace the placeholder values with your actual AWS account IDs and SSO start URL.

## Configuration

### 3. Configure `locals.tf`

Open `locals.tf` and update the following settings:

#### Essential Settings

| Variable | Description | Example |
|----------|-------------|---------|
| `environment` | Environment name for the InfraWeave platform (e.g., `prod`, `dev`, `staging`). Used to distinguish multiple InfraWeave control planes if needed. | `"prod"` |
| `central_account_id` | AWS account ID of your central account | `"123456789101"` |
| `primary_region` | Primary region for global resources (IAM, OIDC) | `"us-west-2"` |
| `all_regions` | List of regions to deploy infrastructure | `["us-west-2", "eu-central-1"]` |

#### GitHub OIDC Configuration

Configure GitHub repositories that need OIDC access to the central account:

```terraform
central_github_repos_oidc = [
  "your-org/your-repo",
  "your-org/another-repo",
]
```

#### Workload Projects Configuration

Define each workload account in the `all_workload_projects` list:

```terraform
all_workload_projects = [
  {
    project_id = "987654321098"  # AWS account ID
    name = "Developer Account"
    description = "Developer Account for testing"
    regions = ["us-west-2", "eu-central-1"]  # Regions for this workload
    github_repos_deploy = [      # Repos with deployment access
      "your-org/deploy-repo",
    ]
    github_repos_oidc = [         # Repos with OIDC access
      "your-org/oidc-repo",
    ]
  }
]
```

### 4. Configure Central Account (`central.tf`)

The `central.tf` file deploys the control plane infrastructure. Key configurations:

- **Module source**: Points to the InfraWeave central module
- **Regions**: Configured via `for_each` loop over `local.all_regions`
- **Primary region settings**: Webhook endpoint and OIDC provider created only in primary region
- **Provider**: Uses `aws.central` profile

Review and adjust if needed, but the default configuration should work for most setups.

### 5. Configure Workload Accounts

For each workload account, create or edit a `.tf` file (e.g., `project1-dev.tf`):

1. **Copy the template**: Duplicate `project1-dev.tf` for each workload account
2. **Update the module name**: Change module identifier to match your project name
3. **Configure the provider**: Ensure the AWS provider references the correct profile
4. **Verify regions**: Ensure regions match those defined in `locals.tf`

**Example workload configuration:**
```terraform
module "project1-dev" {
  source = "git::https://github.com/infraweave-io/terraform-aws-infraweave-workload.git?ref=v0.0.91"
  
  for_each = toset(local.all_regions)
  
  region = each.value
  
  providers = {
    aws = aws.project1-dev
  }
  
  # ... additional configuration
}
```

### 6. Configure Remote State (Recommended)

For production use, configure remote state storage in `backend.tf`:

1. **Create an S3 bucket** for state storage:
```bash
aws s3api create-bucket \
  --bucket your-terraform-state-bucket-unique-name-1234 \
  --region us-west-2 \
  --create-bucket-configuration LocationConstraint=us-west-2

aws s3api put-bucket-versioning \
  --bucket your-terraform-state-bucket-unique-name-1234 \
  --versioning-configuration Status=Enabled
```

2. **Uncomment and update** the backend configuration in `backend.tf`:
```terraform
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket-unique-name-1234"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}
```

## Deployment

### 7. Authenticate with AWS SSO

Log in to AWS SSO to establish an active session:

```bash
aws sso login --sso-session aws-sso-session
```

### 8. Initialize Pull-Through Cache

**First-time setup only**: The pull-through cache improves container image pull performance. 

1. **Make the script executable**:
```bash
chmod +x update_pull_through_cache.sh
```

2. **Edit the script** to match your configuration (account IDs, regions, repositories)

3. **Run the script**:
```bash
./update_pull_through_cache.sh
```

### 9. Deploy Infrastructure

Initialize Terraform and apply the configuration:

```bash
# Initialize Terraform (downloads providers and modules)
terraform init

# Review the execution plan
terraform plan

# Apply the configuration
terraform apply
```

Review the plan carefully, then type `yes` to confirm and deploy.

## Verification ✅

After successful deployment, verify the setup:

1. **Check Terraform outputs**:
```bash
terraform output
```

2. **Verify webhook endpoints** are created in each region

3. **Confirm IAM roles** exist in the AWS console:
   - Central account: Check for InfraWeave control plane roles
   - Workload accounts: Check for deployment and reconciler roles

4. **Test OIDC authentication** from your GitHub Actions workflows

## Upgrades and Updates

To upgrade InfraWeave to a newer version:

1. **Update module versions** in `central.tf` and workload `.tf` files (change `?ref=vX.X.X`)
2. **Re-run the deployment process**:
```bash
terraform init -upgrade
terraform plan
terraform apply
```

## Troubleshooting

### Common Issues

**SSO Session Expired**
```
Error: failed to refresh cached credentials
```
**Solution**: Re-authenticate with `aws sso login --sso-session aws-sso-session`

**Permission Denied on Script**
```
permission denied: ./update_pull_through_cache.sh
```
**Solution**: Run `chmod +x update_pull_through_cache.sh`

**Provider Configuration Error**
```
Error: No valid credential sources found
```
**Solution**: Verify your `~/.aws/config` profiles match the provider configurations in your `.tf` files

**State Lock Error**
```
Error: Error acquiring the state lock
```
**Solution**: If using remote state, ensure no other Terraform process is running. If stuck, you may need to manually unlock: `terraform force-unlock <lock-id>`

### Getting Help

- **Documentation**: [InfraWeave Docs](https://preview.infraweave.io)
- **GitHub Issues**: [Report issues](https://github.com/infraweave-io/aws-bootstrap/issues)
- **Community**: Join our community Slack/Discord

## Security Considerations

- **Never commit sensitive values** (account IDs are not sensitive, but credentials are)
- **Use remote state** with encryption and state locking
- **Review IAM permissions** granted to GitHub OIDC roles
- **Enable CloudTrail** in all accounts for audit logging
- **Regularly rotate** access credentials and review permissions

## Contributing

Contributions are welcome!

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

