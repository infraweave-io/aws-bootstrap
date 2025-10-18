
// Central Account

module "central" {
  source = "git::https://github.com/infraweave-io/terraform-aws-infraweave-central.git?ref=v0.0.91-patch+single-role"

  for_each = toset(local.all_regions)

  region = each.value

  providers = {
    aws = aws.central
  }

  environment = local.environment

  # Enable webhook processor in all regions, but endpoint only in primary
  enable_webhook_processor          = true
  enable_webhook_processor_endpoint = each.value == local.primary_region ? true : false
  
  # Create global IAM resources (OIDC) only in primary region
  create_github_oidc_provider       = each.value == local.primary_region ? true : false

  oidc_allowed_github_repos = local.central_github_repos_oidc
  
  all_regions = local.all_regions
  all_workload_projects = local.all_workload_projects
  is_primary_region = each.value == local.primary_region
}

output "webhook_endpoints" {
  value = {
    for region, module_instance in module.central : 
      region => module_instance.webhook_endpoint
  }
}

// moved blocks for state migration
moved {
  from = module.central-us-west-2
  to   = module.central["us-west-2"]
}

moved {
  from = module.central-eu-central-1
  to   = module.central["eu-central-1"]
}

// Regional provider (single provider with regions set on resources)

provider "aws" {
  alias   = "central"
  profile = "central" # This is the profile name in ~/.aws/config
  default_tags {
    tags = local.tags
  }
}
