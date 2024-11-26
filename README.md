
# Getting started

To get started, you need to bootstrap the AWS accounts to support InfraWeave.

## Set up AWS config

Ensure you have set up profiles for all your accounts, here is an example:

```toml
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

[profile project1-prod]
sso_account_id = 222222222222
regio = us-east-1
sso_session = aws-sso-session
sso_role_name = AdministratorAccess

[profile project2-dev]
sso_account_id = 333333333333
regio = us-east-1
sso_session = aws-sso-session
sso_role_name = AdministratorAccess

[sso-session aws-sso-session]
sso_start_url = https://d-1234567890.awsapps.com/start
sso_region = us-east-1
sso_registration_scopes = sso:account:access
```

## Clone the repo

Clone the [aws-bootstrap](https://github.com/infraweave-io/aws-bootstrap-example) which is designed to make it easy to get started.

It has the following structure:

```
.
├── LICENSE
├── README.md
├── central.tf
├── locals.tf
├── project-1.tf
└── project-2.tf
```

# Configuration

Before you bootstrap the control plane you need to configure it as you want.

## Configure settings

Here are following configurations in `locals.tf`:
* `environment`

By default `environment` is set to "prod", but if you want to have multiple control-planes, this parameter can be used. This local variable is passed to each module. 
In order to use multiple environments, either have a copy of this folder per environment, or modify the code to handle all environments in this folder.

## Configure the central account

Modify the file `central.tf`.

1. Set up one central-module per region you want to support
1. Configure a corresponding provider per region and name accordingly

## Configure each workload account

In this example we have `project1-dev`, `project1-prod` and `project2-dev` to demonstrate how it can be set up, each project has its own `.tf`-file.

1. Set up one workload-module per region you want to support
1. Configure a corresponding provider per region and name accordingly

# Setting up

Perform the bootstrapping by running

```tf
terraform init
terraform apply
```

This will bootstrap the entire platform in all desired AWS accounts.
