variable "region" {
  default = "eu-west-1"
}

variable "env-name" {
}

variable "project-name"{
  default = "terraform-ci-poc"
}

variable "vpc-cidr_block" {
  default = "10.0.0.0/16"
}
variable "cluster_instance_type" {
}
variable "repository_uri" {
  default="752583717420.dkr.ecr.eu-west-1.amazonaws.com/terraform-ci-poc"
}