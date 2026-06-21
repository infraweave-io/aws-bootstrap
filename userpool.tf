
# Global User Pool (Single Instance)
module "user_pool" {
  source = "../terraform-aws-infraweave-central/user-pool"

  environment                  = local.environment
  region                       = local.primary_region
  account_id                   = local.central_account_id

  identity_center_metadata_url = "https://portal.sso.eu-central-1.amazonaws.com/saml/metadata/12345abcdef..."
  identity_center_enabled      = true

  cognito_callback_urls = [
    # "http://localhost:8080/callback",
    "http://localhost:3000/callback",
    "http://localhost:19847/callback",
  ]
  
  cognito_logout_urls = [
    # "http://localhost:8080/callback",
    "http://localhost:3000/logout",
  ]

  # Using aws.central provider which defaults to one region. 
  # Note: Ideally this receives a provider aliased to local.primary_region ("us-west-2")
  providers = {
    aws = aws.central
  }
}

# --------------------------------------------------------------------------
# Example: Using Okta instead of AWS Identity Center
# --------------------------------------------------------------------------
#
# Option 1: Okta SAML → Cognito (replaces Identity Center as the SAML IdP)
# --------------------------------------------------------------------------
# This approach keeps Cognito as the OIDC layer but federates login to Okta
# via SAML. The user-pool module would need its SAML variables generalized
# (e.g. rename identity_center_* → saml_*) or add okta-specific variables.
#
# module "user_pool" {
#   source = "../terraform-aws-infraweave-central/user-pool"
#
#   environment = local.environment
#   region      = local.primary_region
#   account_id  = local.central_account_id
#
#   # Replace Identity Center with Okta SAML metadata
#   # 1. In Okta: Create a new SAML 2.0 app integration
#   # 2. Set the ACS URL to:
#   #      https://infraweave-webserver-<env>-<account_id>.auth.<region>.amazoncognito.com/saml2/idpresponse
#   # 3. Set the Audience URI (SP Entity ID) to:
#   #      urn:amazon:cognito:sp:<user_pool_id>
#   # 4. Map attributes: email → user.email
#   # 5. Copy the metadata URL from Okta's "Sign On" tab
#   identity_center_enabled      = true   # controls SAML provider creation
#   identity_center_metadata_url = "https://your-org.okta.com/app/exk.../sso/saml/metadata"
#
#   cognito_callback_urls = [
#     "http://localhost:8080/callback",
#     "http://localhost:3000/callback",
#     "https://your-app-domain.com/callback",
#   ]
#
#   cognito_logout_urls = [
#     "http://localhost:8080/callback",
#     "http://localhost:3000/logout",
#     "https://your-app-domain.com/logout",
#   ]
#
#   providers = {
#     aws = aws.central
#   }
# }
#
# Note: You will also need to update the provider_name in the user-pool module
# from "IdentityCenter" to "Okta" in aws_cognito_identity_provider for clarity.
#
# --------------------------------------------------------------------------
# Option 2: Okta OIDC directly (bypass Cognito entirely)
# --------------------------------------------------------------------------
# This approach removes Cognito and points auth_config directly at Okta's
# OIDC endpoints. You would no longer need the user_pool module at all.
#
# 1. In Okta: Create an OIDC Web Application
# 2. Set sign-in redirect URIs to your callback URLs
# 3. Set sign-out redirect URIs to your logout URLs
# 4. Note the Client ID and Okta domain
#
# Then replace the auth_config block in module "central" with:
#
# module "central" {
#   source   = "../terraform-aws-infraweave-central"
#   for_each = toset(local.all_regions)
#   region   = each.value
#   ...
#
#   auth_config = {
#     issuer_url   = "https://your-org.okta.com/oauth2/default"   # or a custom authorization server
#     client_id    = "0oa..."                                      # Okta OIDC app client ID
#     domain       = "your-org.okta.com"                           # used for login redirects
#     user_pool_id = ""                                            # not applicable for Okta
#   }
#   ...
# }
#
# With Option 2, the API Gateway JWT authorizer will validate tokens directly
# against Okta's JWKS endpoint (/.well-known/jwks.json) — no Cognito needed.
# --------------------------------------------------------------------------
