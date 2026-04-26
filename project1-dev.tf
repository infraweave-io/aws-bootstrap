
// Workload Account Project 1 (dev)

module "workload-project1-dev" {
  source = "git::https://github.com/infraweave-io/terraform-aws-infraweave-workload.git?ref=v0.0.91-patch+single-role"

  for_each = toset(local.all_regions)

  region = each.value

  providers = {
    aws = aws.workload-project1-dev
  }

  environment        = local.environment
  central_account_id = local.central_account_id

  # Only pass all_workload_projects in the primary region
  all_workload_projects = each.value == local.primary_region ? local.all_workload_projects : []
  is_primary_region     = each.value == local.primary_region

  # CloudWatch Observability — per-region link to the same-region central sink
  enable_observability           = true
  central_observability_sink_arn = module.central[each.value].observability_sink_arn : ""
}

// moved blocks for state migration
moved {
  from = module.workload-project1-dev-us-west-2
  to   = module.workload-project1-dev["us-west-2"]
}

moved {
  from = module.workload-project1-dev-eu-central-1
  to   = module.workload-project1-dev["eu-central-1"]
}

// Regional provider (single provider with regions set on resources)

provider "aws" {
  alias   = "workload-project1-dev"
  profile = "project1-dev" # This is the profile name in ~/.aws/config
  default_tags {
    tags = local.tags
  }
}