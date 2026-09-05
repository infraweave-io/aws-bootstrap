
locals {
  environment        = "prod"
  central_account_id = "000000000000"
  primary_region     = "us-west-2" # Primary region for global resources (IAM, OIDC, etc.)
  
  telemetry_exporter = "xray"
  enable_transaction_search              = true
  transaction_search_indexing_percentage = 100

  tags = {
    Environment = local.environment
    Application = "InfraWeave"
    # Add more tags as needed
  }

  all_regions = ["us-west-2", "eu-central-1"]

  cors_allow_origins = [
    "http://localhost:3000",
  ]

  central_github_repos_oidc = [
    "some-org/module1", 
    "some-org/module2"
  ]

  all_workload_projects = [
      {
        project_id = "111111111111"
        name = "Developer Account"
        description = "Developer Account for testing"
        regions = ["us-west-2", "eu-central-1"]
        github_repos_deploy = [
          "some-org/infra-111111111111",
        ]
        github_repos_oidc = [ 
          "some-org/module1", # Can be used for tests in this account
          "some-org/module2", # Can be used for tests in this account
        ]
      }
  ]

  publish_auth_rego_policy = file("${path.module}/publish_auth.rego")

  enable_service_level_objectives = true
  slo_availability_attainment     = 99
  slo_availability_warning        = 99.5
  slo_latency_threshold_ms = 500
  telemetry_environment_central = "central-${local.environment}"

}
