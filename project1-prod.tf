
// Workload Account Project 1 (prod)

module "workload-project1-prod-us-west-2" {
  source = "git::https://github.com/infraweave-io/terraform-aws-infraweave-workload.git?ref=v0.0.1"

  region = "us-west-2"
  providers = {
    aws = aws.workload-project1-prod-us-west-2
  }

  environment        = local.environment
  central_account_id = local.central_account_id
  organization_id = local.organization_id
}

module "workload-project1-prod-eu-central-1" {
  source = "git::https://github.com/infraweave-io/terraform-aws-infraweave-workload.git?ref=v0.0.1"

  region = "eu-central-1"
  providers = {
    aws = aws.workload-project1-prod-eu-central-1
  }

  environment        = local.environment
  central_account_id = local.central_account_id
  organization_id = local.organization_id
}

// Regional providers

provider "aws" {
  alias   = "workload-project1-prod-us-west-2"
  region  = "us-west-2"
  profile = "project1-prod" # This is the profile name in ~/.aws/config
}

provider "aws" {
  alias   = "workload-project1-prod-eu-central-1"
  region  = "eu-central-1"
  profile = "project1-prod" # This is the profile name in ~/.aws/config
}
