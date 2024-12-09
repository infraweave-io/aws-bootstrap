
// Workload Account Project 1 (dev)

module "workload-project1-dev-us-west-2" {
  source = "git::https://github.com/infraweave-io/terraform-aws-infraweave-workload.git?ref=v0.0.3"

  region = "us-west-2"
  providers = {
    aws = aws.workload-project1-dev-us-west-2
  }

  environment        = local.environment
  central_account_id = local.central_account_id
  organization_id = local.organization_id
}

module "workload-project1-dev-eu-central-1" {
  source = "git::https://github.com/infraweave-io/terraform-aws-infraweave-workload.git?ref=v0.0.3"

  region = "eu-central-1"
  providers = {
    aws = aws.workload-project1-dev-eu-central-1
  }

  environment        = local.environment
  central_account_id = local.central_account_id
  organization_id = local.organization_id
}

// Regional providers

provider "aws" {
  alias   = "workload-project1-dev-us-west-2"
  region  = "us-west-2"
  profile = "project1-dev" # This is the profile name in ~/.aws/config
}

provider "aws" {
  alias   = "workload-project1-dev-eu-central-1"
  region  = "eu-central-1"
  profile = "project1-dev" # This is the profile name in ~/.aws/config
}
