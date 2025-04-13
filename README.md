
# Getting Started 🚀

Welcome to InfraWeave! This guide will walk you through bootstrapping your AWS accounts to support the InfraWeave platform.

## Set Up AWS Config 🔧

Before you begin, ensure you have configured profiles for all your AWS accounts. Below is an example configuration for your `~/.aws/config` file:

```ini
# Filename: ~/.aws/config

# ...

[profile central]
sso_account_id = 000000000000
regio = us-east-1
sso_session = aws-sso-session
sso_role_name = AdministratorAccess

[profile project1-dev]
sso_account_id = 111111111111
regio = us-east-1
sso_session = aws-sso-session
sso_role_name = AdministratorAccess

[sso-session aws-sso-session]
sso_start_url = https://d-1234567890.awsapps.com/start
sso_region = us-east-1
sso_registration_scopes = sso:account:access
```

## Clone the Repository 📥

Clone [this](https://github.com/infraweave-io/aws-bootstrap), designed to simplify your setup process. The repository structure is as follows:

```
.
├── LICENSE
├── README.md
├── central.tf
├── locals.tf
├── project1-dev.tf
└── update_pull_through_cache.sh
```

# Configuration ⚙️

Before bootstrapping the control plane, configure it according to your environment’s requirements.

## Configure Settings

Within `locals.tf`, review and update the following configuration:
* `environment`

environment: By default, this is set to `"prod"`. If you need to support multiple control planes, adjust this parameter accordingly. You can either duplicate the folder for each environment or modify the code to manage multiple environments within the same directory.

## Configure the Central Account

Edit the `central.tf` file to:

1. Set up one central module per supported region.
1. Configure a corresponding provider for each region, naming them appropriately.

## Configure each Workload Account

For each project (e.g., `project1-dev`), a dedicated `.tf` file is provided. Within these files:

1. Set up one workload module per supported region.
1. Configure the corresponding provider for each region, with appropriate naming.

# Bootstrapping the Platform 🚀

1. **SSO Login**: Ensure you have an active SSO session:
```bash
aws sso login --profile sso-session
```

2. **Initialize the Pull-Through Cache**: Before bootstrapping the infrastructure for the first time, set up and populate the pull-through cache. Modify and run the provided script:
```bash
./update_pull_through_cache.sh
```

3. **Run Terraform**: Execute the following commands to bootstrap your entire platform across all desired AWS accounts:
```bash
terraform init
terraform apply
```

*Note: Repeat these steps for upgrades as well.*