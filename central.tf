
// Central Account

module "central" {
  source = "git::https://github.com/infraweave-io/terraform-aws-infraweave-central.git?ref=v0.0.91-patch+single-role"

  for_each = toset(local.all_regions)

  region = each.value

  providers = {
    aws = aws.central
  }

  environment = local.environment

  # Pass generic auth configuration derived from the Cognito User Pool
  auth_config = {
    issuer_url   = module.user_pool.issuer_url
    client_id    = module.user_pool.user_pool_client_id
    domain       = module.user_pool.user_pool_domain
    user_pool_id = module.user_pool.user_pool_id
  }

  # Enable webhook processor in all regions, but endpoint only in primary
  enable_webhook_processor          = true
  enable_webhook_processor_endpoint = each.value == local.primary_region ? true : false

  # Create global IAM resources (OIDC) only in primary region
  create_github_oidc_provider = each.value == local.primary_region ? true : false

  oidc_allowed_github_repos = local.central_github_repos_oidc

  all_regions           = local.all_regions
  all_workload_projects = local.all_workload_projects
  is_primary_region     = each.value == local.primary_region

  cors_allow_origins = local.cors_allow_origins

  enable_waf = false

  publish_auth_rego_policy = local.publish_auth_rego_policy
}

output "webhook_endpoints" {
  value = {
    for region, module_instance in module.central :
    region => module_instance.webhook_endpoint
  }
}

output "webserver_endpoints" {
  value = {
    for region, module_instance in module.central :
    region => module_instance.webserver_api_gateway_url
  }
}

output "observability_sink_arns" {
  description = "ARNs of the CloudWatch Observability Access Manager sinks per region"
  value = {
    for region, module_instance in module.central :
    region => module_instance.observability_sink_arn
  }
}

output "observability_sink_ids" {
  description = "IDs of the CloudWatch Observability Access Manager sinks per region"
  value = {
    for region, module_instance in module.central :
    region => module_instance.observability_sink_id
  }
}

output "webserver_frontend_config" {
  description = "Frontend environment variables for React app configuration"
  value       = module.central[local.primary_region].webserver_frontend_config
}

output "webserver_auth_issuer_url" {
  description = "OIDC issuer URL"
  value       = module.central[local.primary_region].webserver_auth_issuer_url
}

output "webserver_auth_client_id" {
  description = "OIDC client ID"
  value       = module.central[local.primary_region].webserver_auth_client_id
}

output "webserver_auth_domain" {
  description = "Auth domain for frontend login"
  value       = module.central[local.primary_region].webserver_auth_domain
}

output "webserver_api_gateway_url" {
  description = "API Gateway URL for frontend"
  value       = module.central[local.primary_region].webserver_api_gateway_url
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
