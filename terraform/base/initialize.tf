provider "aws" {
  region = "${var.region}"
}

module "vpc" {
  source        = "github.com/itsdalmo/tf-modules//ec2/vpc"
  prefix        = "${var.env-name}-${var.project-name}"
  cidr_block    = "${var.vpc-cidr_block}"
  dns_hostnames = "true"

  tags{
    environment = "${var.env-name}"
    terraform   = "true"
  }
}
module "alb" {
  source        = "github.com/itsdalmo/tf-modules//ec2/alb"
  prefix        = "${var.env-name}-${var.project-name}"
  internal      = "false"
  vpc_id        = "${module.vpc.vpc_id}"
  subnet_ids    = ["${module.vpc.public_subnet_ids}"]
}

module "cluster"{
  source = "github.com/itsdalmo/tf-modules//container/cluster"
  prefix        = "${var.env-name}-${var.project-name}"
  vpc_id        = "${module.vpc.vpc_id}"
  subnet_ids    = ["${module.vpc.public_subnet_ids}"]
  instance_type = "${var.cluster_instance_type}"
}


