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
    kms_key_id     = "arn:aws:kms:eu-west-1:276208424594:key/90b6fd6f-925c-4426-88e6-214955de0030"
    region         = "eu-west-1"
  }
}

provider "aws" {
  version             = "1.7.1"
  region              = "${var.region}"
  allowed_account_ids = ["653090749433"]
}
