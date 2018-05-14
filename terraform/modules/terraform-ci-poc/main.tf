data "aws_caller_identity" "current" {}

module "vpc" {
  source          = "github.com/TeliaSoneraNorge/telia-terraform-modules//ec2/vpc?ref=b636148"
  prefix          = "${var.prefix}"
  cidr_block      = "${var.vpc-cidr_block}"
  private_subnets = "${var.private_subnet_count}"
  dns_hostnames   = "true"
  tags            = "${var.tags}"
}

module "lb" {
  source     = "github.com/TeliaSoneraNorge/telia-terraform-modules//ec2/lb?ref=b636148"
  prefix     = "${var.prefix}"
  type       = "application"
  internal   = "false"
  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = ["${module.vpc.public_subnet_ids}"]
  tags       = "${var.tags}"
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
  source              = "github.com/TeliaSoneraNorge/telia-terraform-modules//ecs/spotfleet-cluster?ref=b636148"
  prefix              = "${var.prefix}"
  subnets             = "${module.vpc.private_subnet_ids}"
  subnet_count        = "3"
  target_capacity     = 3
  allocation_strategy = "lowestPrice"
  tags                = "${var.tags}"
  spot_price          = "0.02"
  load_balancers      = ["${module.lb.security_group_id}"]
  load_balancer_count = "1"
  vpc_id              = "${module.vpc.vpc_id}"
}

module "terraform-ci-poc-service" {
  source          = "github.com/TeliaSoneraNorge/divx-terraform-modules//ecs/service?ref=b636148"
  prefix          = "${var.prefix}"
  vpc_id          = "${module.vpc.vpc_id}"
  cluster_id      = "${module.cluster.id}"
  cluster_role_id = "${module.cluster.role_id}"

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
  task_container_count  = "2"
}
