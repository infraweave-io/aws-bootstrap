
// Workload Account Project 2 (dev)

module "workload-project2-dev-us-west-2" {
  source = "git::https://github.com/infraweave-io/terraform-aws-infraweave-workload.git?ref=v0.0.3"

  region = "us-west-2"
  providers = {
    aws = aws.workload-project2-dev-us-west-2
  }

  environment        = local.environment
  central_account_id = local.central_account_id
  organization_id = local.organization_id
}

module "workload-project2-dev-eu-central-1" {
  source = "git::https://github.com/infraweave-io/terraform-aws-infraweave-workload.git?ref=v0.0.3"

  region = "eu-central-1"
  providers = {
    aws = aws.workload-project2-dev-eu-central-1
  }

  environment        = local.environment
  central_account_id = local.central_account_id
  organization_id = local.organization_id
}

// Regional providers

provider "aws" {
  alias   = "workload-project2-dev-us-west-2"
  region  = "us-west-2"
  profile = "project2-dev" # This is the profile name in ~/.aws/config
}

provider "aws" {
  alias   = "workload-project2-dev-eu-central-1"
  region  = "eu-central-1"
  profile = "project2-dev" # This is the profile name in ~/.aws/config
}
