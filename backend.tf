
# Strongly recommended to use a remote backend for storing the Terraform state file.
# Read more here https://developer.hashicorp.com/terraform/language/backend/s3

# Note that this has to be another bucket, example how to create a bucket:

# aws s3api create-bucket --bucket <your bucket name> --region <region>
# aws s3api put-bucket-versioning --bucket <your bucket name> --versioning-configuration Status=Enabled

# Uncomment the following lines to use a remote backend:

# terraform {
#   backend "s3" {
#     bucket = <your bucket name>
#     key    = "terraform.tfstate"
#     region = <region>
#   }
# }