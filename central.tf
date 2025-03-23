
// Central Account

module "central-us-west-2" {
  source = "git::https://github.com/infraweave-io/terraform-aws-infraweave-central.git?ref=v0.0.69"

  region = "us-west-2"
  providers = {
    aws = aws.central-us-west-2
  }

  environment = local.environment
  organization_id = local.organization_id
  central_account_id = local.central_account_id

  enable_webhook_processor = true
  enable_webhook_processor_endpoint = true

  oidc_allowed_github_repos = local.central_github_repos_oidc
  
  all_regions = local.all_regions
  all_workload_projects = local.all_workload_projects
}

output "webhook_endpoint_us_west_2" {
  value = module.central-us-west-2.webhook_endpoint
}

module "central-eu-central-1" {
  source = "git::https://github.com/infraweave-io/terraform-aws-infraweave-central.git?ref=v0.0.69"

  region = "eu-central-1"
  providers = {
    aws = aws.central-eu-central-1
  }

  environment = local.environment
  organization_id = local.organization_id
  central_account_id = local.central_account_id

  enable_webhook_processor = true

  all_regions = local.all_regions
  all_workload_projects = local.all_workload_projects

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
