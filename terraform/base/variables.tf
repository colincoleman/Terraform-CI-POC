variable "workshop-common-infrastructure-remote_state_bucket" {}
variable "workshop-common-infrastructure-remote_state_region" {}
variable "workshop-common-infrastructure-remote_state_key" {}
variable "workshop-common-infrastructure-remote_state_kms_key_id" {}

variable "region" {
  default = "eu-west-1"
}

variable "env-name" {}

variable "project-name" {
  default = "terraform-ci-poc"
}

variable "vpc-cidr_block" {
  default = "10.0.0.0/16"
}

variable "cluster_instance_type" {}

variable "cluster_instance_count" {}

variable "instance_key" {
  default = ""
}

variable "repository_uri" {
  default = "653090749433.dkr.ecr.eu-west-1.amazonaws.com/terraform-ci-poc"
}

variable "tags" {
  type = "map"

  default = {
    terraform   = "True"
    environment = "dev"
  }
}
