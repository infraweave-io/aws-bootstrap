
// Workload Account Project 1 (dev)

module "workload-project1-dev-us-west-2" {
  source = "git::https://github.com/infraweave-io/terraform-aws-infraweave-workload.git?ref=v0.0.73"

  region = "us-west-2"
  providers = {
    aws = aws.workload-project1-dev-us-west-2
  }

  environment        = local.environment
  central_account_id = local.central_account_id

  all_workload_projects = local.all_workload_projects # Only to be set in the primary region of the workload account
}

module "workload-project1-dev-eu-central-1" {
  source = "git::https://github.com/infraweave-io/terraform-aws-infraweave-workload.git?ref=v0.0.73"

  region = "eu-central-1"
  providers = {
    aws = aws.workload-project1-dev-eu-central-1
  }

  environment        = local.environment
  central_account_id = local.central_account_id
}

// Regional providers

provider "aws" {
  alias   = "workload-project1-dev-us-west-2"
  region  = "us-west-2"
  profile = "project1-dev" # This is the profile name in ~/.aws/config
  default_tags {
    tags = local.tags
  }
}

provider "aws" {
  alias   = "workload-project1-dev-eu-central-1"
  region  = "eu-central-1"
  profile = "project1-dev" # This is the profile name in ~/.aws/config
  default_tags {
    tags = local.tags
  }
}
