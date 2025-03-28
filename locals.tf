
locals {
  environment        = "prod"
  central_account_id = "000000000000"
  tags = {
    Environment = local.environment
    Application = "InfraWeave"
    # Add more tags as needed
  }

  all_regions = ["us-west-2", "eu-central-1"]

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
}