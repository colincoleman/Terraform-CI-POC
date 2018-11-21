data "aws_caller_identity" "current" {}

module "vpc" {
  source               = "telia-oss/vpc/aws"
  version              = "0.2.0"
  name_prefix          = "${var.prefix}"
  cidr_block           = "${var.vpc-cidr_block}"
  private_subnet_count = "${var.private_subnet_count}"
  create_nat_gateways  = "true"
  enable_dns_hostnames = "true"
  tags                 = "${var.tags}"
}

module "lb" {
  source      = "telia-oss/loadbalancer/aws"
  version     = "0.1.1"
  name_prefix = "${var.prefix}"
  type        = "application"
  internal    = "false"
  vpc_id      = "${module.vpc.vpc_id}"
  subnet_ids  = ["${module.vpc.public_subnet_ids}"]
  tags        = "${var.tags}"
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = "${module.lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${module.terraform-ci-poc-service.target_group_arn}"
    type             = "forward"
  }
}

resource "aws_security_group_rule" "ingress_80" {
  security_group_id = "${module.lb.security_group_id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  cidr_blocks       = ["0.0.0.0/0"]
}

module "cluster" {
  source              = "telia-oss/ecs/aws//modules/cluster"
  version             = "0.6.1"
  name_prefix         = "${var.prefix}"
  subnet_ids          = "${module.vpc.private_subnet_ids}"
  min_size            = "1"
  instance_type       = "t3.small"
  tags                = "${var.tags}"
  load_balancers      = ["${module.lb.security_group_id}"]
  load_balancer_count = "1"
  vpc_id              = "${module.vpc.vpc_id}"
  instance_ami        = "ami-0651de2fa6ccf6d26"
  instance_key        = "xqb-dev"
}

module "terraform-ci-poc-service" {
  source            = "telia-oss/ecs/aws//modules/service"
  version           = "0.3.0"
  name_prefix       = "${var.prefix}"
  vpc_id            = "${module.vpc.vpc_id}"
  cluster_id        = "${module.cluster.id}"
  cluster_role_name = "${module.cluster.role_name}"

  target {
    protocol      = "HTTP"
    port          = "5050"
    load_balancer = "${module.lb.arn}"
  }

  health {
    port    = "traffic-port"
    path    = "/"
    matcher = "200"
  }

  task_definition_image = "${var.repository_uri}:latest"
  desired_count         = "2"
}

module "agent-policy" {
  source      = "telia-oss/ssm-agent-policy/aws"
  version     = "0.1.1"
  name_prefix = "${var.prefix}"
  role        = "${module.cluster.role_name}"
}
