variable "prefix" {
  default = "terraform-ci-poc"
}

variable "vpc-cidr_block" {
  default = "10.0.0.0/16"
}

variable "repository_uri" {}

variable "tags" {
  type = "map"

  default = {
    terraform   = "True"
    environment = "dev"
  }
}

variable "private_subnet_count" {}
