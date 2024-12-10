
locals {
  organization_id    = "o-abc123456"
  environment        = "prod"
  central_account_id = "000000000000"
  tags = {
    Environment = local.environment
    Application = "InfraWeave"
    # Add more tags as needed
  }
}