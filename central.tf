
// Central Account

module "central-us-west-2" {
  source = "git::https://github.com/infraweave-io/terraform-aws-infraweave-central.git?ref=v0.0.2"

  region = "us-west-2"
  providers = {
    aws = aws.central-us-west-2
  }

  environment = local.environment
  organization_id = local.organization_id
  central_account_id = local.central_account_id
}

module "central-eu-central-1" {
  source = "git::https://github.com/infraweave-io/terraform-aws-infraweave-central.git?ref=v0.0.2"

  region = "eu-central-1"
  providers = {
    aws = aws.central-eu-central-1
  }

  environment = local.environment
  organization_id = local.organization_id
  central_account_id = local.central_account_id
}

// Regional providers

provider "aws" {
  alias   = "central-us-west-2"
  region  = "us-west-2"
  profile = "central" # This is the profile name in ~/.aws/config
}

provider "aws" {
  alias   = "central-eu-central-1"
  region  = "eu-central-1"
  profile = "central" # This is the profile name in ~/.aws/config
}
