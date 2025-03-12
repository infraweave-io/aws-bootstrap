
// Central Account

module "central-us-west-2" {
  source = "git::https://github.com/infraweave-io/terraform-aws-infraweave-central.git?ref=v0.0.60"

  region = "us-west-2"
  providers = {
    aws = aws.central-us-west-2
  }

  environment = local.environment
  organization_id = local.organization_id
  central_account_id = local.central_account_id

  enable_webhook_processor = true # Optional
  enable_webhook_processor_endpoint = true # Optional

  enable_oidc_provider = true # Optional
  allowed_github_repos = [ "some-org/example-repo" ] # Optional
  
  project_map = local.project_map # Optional
}

output "webhook_endpoint_us_west_2" {
  value = module.central-us-west-2.webhook_endpoint
}

module "central-eu-central-1" {
  source = "git::https://github.com/infraweave-io/terraform-aws-infraweave-central.git?ref=v0.0.60"

  region = "eu-central-1"
  providers = {
    aws = aws.central-eu-central-1
  }

  environment = local.environment
  organization_id = local.organization_id
  central_account_id = local.central_account_id

  enable_webhook_processor = true # Optional

  project_map = local.project_map # Optional
}

// Regional providers

provider "aws" {
  alias   = "central-us-west-2"
  region  = "us-west-2"
  profile = "central" # This is the profile name in ~/.aws/config
  default_tags {
    tags = local.tags
  }
}

provider "aws" {
  alias   = "central-eu-central-1"
  region  = "eu-central-1"
  profile = "central" # This is the profile name in ~/.aws/config
  default_tags {
    tags = local.tags
  }
}
