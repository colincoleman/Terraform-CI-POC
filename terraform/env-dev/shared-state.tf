# ------------------------------------------------------------------------------
# State/provider
# ------------------------------------------------------------------------------
terraform {
  required_version = "0.11.1"

  backend "s3" {
    key            = "xqb/terraform-ci-poc.tfstate"
    bucket         = "276208424594-terraform-state"
    dynamodb_table = "276208424594-terraform-state"
    acl            = "bucket-owner-full-control"
    encrypt        = "true"
    kms_key_id     = "arn:aws:kms:eu-west-1:276208424594:key/90b6fd6f-925c-4426-88e6-214955de0030"
    region         = "eu-west-1"
  }
}

provider "aws" {
  version             = "1.5.0"
  region              = "${var.region}"
  allowed_account_ids = ["276208424594"]
}
