# ------------------------------------------------------------------------------
# State/provider
# ------------------------------------------------------------------------------
terraform {
  required_version = "0.10.7"

  backend "s3" {
    key            = "terraform-ci-poc/terraform-ci-poc.tfstate"
    bucket         = "752583717420-terraform-state"
    dynamodb_table = "752583717420-terraform-state"
    acl            = "bucket-owner-full-control"
    encrypt        = "true"
    kms_key_id     = "arn:aws:kms:eu-west-1:752583717420:key/86801c43-5eb3-4729-af1c-7fe9ff1ba54d"
    region         = "eu-west-1"
  }
}

provider "aws" {
  version             = "1.1.0"
  region              = "${var.region}"
  allowed_account_ids = ["752583717420"]
}