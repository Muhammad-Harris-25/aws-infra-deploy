# Optional backend configuration for Terraform state (uncomment and set values)
# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "aws-infra-deploy/terraform.tfstate"
#     region         = "eu-north-1"
#     dynamodb_table = "terraform-lock-table"
#     encrypt        = true
#   }
# }
