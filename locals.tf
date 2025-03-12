
locals {
  organization_id    = "o-abc123456"
  environment        = "prod"
  central_account_id = "000000000000"
  tags = {
    Environment = local.environment
    Application = "InfraWeave"
    # Add more tags as needed
  }

  project_map = jsonencode({
    id = "project_map",
    data = {
      "some-org/infra-111111111111-us-west-2" = {
          project_id = "111111111111"
          region = "us-west-2"
      },
      "some-org/infra-111111111111-eu-central-1" = {
          project_id = "111111111111"
          region = "eu-central-1"
      },
    }
  })
}