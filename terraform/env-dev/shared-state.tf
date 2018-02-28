# ------------------------------------------------------------------------------
# State/provider
# ------------------------------------------------------------------------------
terraform {
  required_version = "0.11.3"

  backend "s3" {
    key            = "workshop/terraform-ci-poc.tfstate"
    bucket         = "653090749433-terraform-state"
    dynamodb_table = "653090749433-terraform-state"
    acl            = "bucket-owner-full-control"
    encrypt        = "true"
    kms_key_id     = "arn:aws:kms:eu-west-1:653090749433:key/ba4a73a8-a71f-4fda-8457-d7a43886f19e"
    region         = "eu-west-1"
  }
}

provider "aws" {
  version             = "1.7.1"
  region              = "eu-west-1"
  allowed_account_ids = ["653090749433"]
}
