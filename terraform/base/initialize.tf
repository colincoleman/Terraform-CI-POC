module "vpc" {
  source        = "github.com/itsdalmo/tf-modules//ec2/vpc?ref=0.1.0"
  prefix        = "${var.env-name}-${var.project-name}"
  cidr_block    = "${var.vpc-cidr_block}"
  dns_hostnames = "true"

  tags{
    environment = "${var.env-name}"
    terraform   = "true"
  }
}
module "alb" {
  source        = "github.com/itsdalmo/tf-modules//ec2/alb?ref=0.1.0"
  prefix        = "${var.env-name}-${var.project-name}"
  internal      = "false"
  vpc_id        = "${module.vpc.vpc_id}"
  subnet_ids    = ["${module.vpc.public_subnet_ids}"]
}

resource "aws_security_group_rule" "ingress_443" {
  security_group_id = "${module.alb.security_group_id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  cidr_blocks       = ["0.0.0.0/0"]
}

module "cluster"{
  source = "github.com/itsdalmo/tf-modules//container/cluster?ref=0.1.0"
  prefix        = "${var.env-name}-${var.project-name}"
  vpc_id        = "${module.vpc.vpc_id}"
  subnet_ids    = ["${module.vpc.public_subnet_ids}"]
  instance_type = "${var.cluster_instance_type}"
}

resource "aws_cloudwatch_log_group" "main" {
  name = "${var.project-name}-${var.env-name}"
}


resource "aws_ecs_task_definition" "terraform-ci-poc" {
  family = "${var.project-name}"
  container_definitions = <<EOF
[
  {
    "name": "${var.project-name}",
    "image": "${var.repository_uri}:latest",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "portMappings": [
      {
        "HostPort": 0,
        "ContainerPort": 5050
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.main.name}",
        "awslogs-region": "${var.region}"
      }
    }
  }
]
EOF
}

module "terraform-ci-service" {
  source = "github.com/baardl/tf-modules//container/service"

  prefix = "${var.project-name}"
  environment = "${var.env-name}"
  vpc_id = "${module.vpc.vpc_id}"
  cluster_id = "${module.cluster.id}"
  cluster_sg = "${module.cluster.security_group_id}"
  cluster_role = "${module.cluster.role_id}"
  load_balancer_name = "${module.alb.name}"
  load_balancer_sg = "${module.alb.security_group_id}"
  task_definition = "${aws_ecs_task_definition.terraform-ci-poc.arn}"
  task_log_group_arn = "${aws_cloudwatch_log_group.main.arn}"
  target_group_arn = "${aws_alb_target_group.terraform-ci-poc-tg.arn}"
  container_count = "1"

  port_mapping = {
    "5050" = "5050"
  }
}

resource "aws_alb_target_group" "terraform-ci-poc-tg" {
  name     = "${var.project-name}-tg"
  port     = 5050
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"
  health_check = {
    interval  = 30,
    path      = "/",
    port      = "traffic-port",
    protocol  = "HTTP",
    timeout   = 5,
    healthy_threshold = 5,
    unhealthy_threshold = 2,
    matcher   = "200,202"
  }
}

variable "certificate_arn" {
  default = "arn:aws:acm:eu-west-1:752583717420:certificate/f32438bb-e112-4b68-bb1e-fc6a713e576d"
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = "${module.alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.terraform-ci-poc-tg.arn}"
    type             = "forward"
  }
}

data "aws_route53_zone" "iot-zone" {
  name         = "iot.telia.io."
  private_zone = false
}

resource "aws_route53_record" "terraform-ci-poc" {
  zone_id = "${data.aws_route53_zone.iot-zone.zone_id}"
  name    = "${var.env-name}-terraform-ci-poc.${data.aws_route53_zone.iot-zone.name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.alb.dns_name}"]
}

resource "aws_security_group_rule" "dynamic_port_mapping" {
  type                     = "ingress"
  security_group_id        = "${module.cluster.security_group_id}"
  protocol                 = "tcp"
  from_port                = 32768
  to_port                  = 65535
  source_security_group_id = "${module.alb.security_group_id}"
}

resource "aws_key_pair" "ssh_key_for_cluster" {
  key_name   = "${var.env-name}-${var.project-name}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDgc2VhScUhekS3WYe1gF54W0Z0Hs0LZrpRopaEMdUmGkIIdlIMzUh/BVckneEtzy8nigkpoeEWf2n+kqFmYSlfUk5AvQZ9EIgwLuitjxqpCplOZQVB9TcMn2G3DLeb1VGl7YjvnsPZqQvS9ZHPO1j1+G5QNh12Bf8AjJlkfwxnza+zAeGac8mtncSTRcvoD0WxZ366VGOG2Lz+e5uLduxnDloxDF5QiAOsvrEnISVfCh33fYD//QhyqFwXqEVNmQq8iTEaU5ikRMIXikFssVygouGyhSl5BiQrwIuFn9eBMraSZCsgA0IM27sptN7cGVvkj9EkkPi3ewiW+JZu3jVx"
}
module "bastion" {
  source      = "github.com/itsdalmo/tf-modules//bastion"
  prefix      = "${var.env-name}-${var.project-name}"
  vpc_id      = "${module.vpc.vpc_id}"
  subnet_ids  = "${module.vpc.public_subnet_ids}"
  pem_bucket  = "tn-lab-config"
  pem_path    = "${var.env-name}-${var.project-name}.pem"

  authorized_keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjdPyZOoO1wvs3vuYwonsNHNIBkOc1GmxmwmygtfIxEs0CxJ/xD12BSNKX+YcwShY7Vi350JXg5kzoWNvru3i7BAz5SVoLsXJlyFnOaHqVzqY9Yfd3T0WM0gW/q/Jgl8nnu0HniNFWBlvaLkTmbBRa7bAsD7BydNYj8uaCXDiVMhJ/A8BLZZXgPKjWVFz31aTvqA4NF9ofXPh+oH5QK8WSG6lP01/do2Vk3wHoQC/yOex1B7mNv4pAfQboW4lriH18M/pnBrLTUuCURRxoioQ6zT7Zpz2h1GUBibeC1CwsLBSCY52ERLltjwwGqNG2VPKyA1/3vGxfJIU7sCkkmlUXD2Al+a6Z3WchJcd+fM0INhZ6454FCyqoEil4cxc78Qp20YQFjjm0q5YZhl1MuDEpi08OcredrwZ6Bo4ZlCypO0uVFNwg5KMWbYZa8PmNGUQKGnOdxykYlXTZvgI7ycZTaZodWYCBl3MGhe4NZoWEEomVnZSSIz+04jlL6DIZlkFm+VRE86xPW5Z8dsa+N8+x+9YPhw3nkeNs37Xc2PMbGj3rFs6c17B4zAk8aMCJSccVwUoXQPsfeTxkISeANZgKXBFqHLiA3pNj8cySeGnwG78SZV55jHYRsAAvOAVAwdQWZ0E4QJDsxDWJ9yXd0ouH0twdYtmvYzmQ7jeMZUhzdw== cc@csquared.me.uk",
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFq+JlxTGZCAG7UOxQTJ4F13C9m6R4t6g405Mjn4FdguAvXQEc5/C11Gzl5ESyl7Ir9uWTgRGkAhDRsFlcSErOB41Z6sWx+XA2OP5co4fxKrTBI39vo7DOsmO6KlT0pNRDvjfjAmGg6QCVT1lIRqG/U//fQfUiPtLxH1brSMnpLfF9I3zmMFEuJhTzab8ZObYQuRlTQBIU4deoahvbTfXIu6Eg7kHJl2Y2CKkuZ5rnTyna4dptjh6L2GuyDEyCIc6RvX7Oj95z0DJ3zMOUOW8zXuL1QgpzqIphVFakUPQUq39XWVl6F+IC8qkhxnxDXBGA9JARC3+EAJn9F2Gv+6QcCB32VFKT2iR82Uoh1uF8N5q8jspsszVR5ftbkE27WBvjMDlBR0GfFOsBFIENtkbhCC1OHQEAhP/LOWu0Bw3QPl4BzBympEm24SoZvPfbqXlLT3OFVMfDuI0pKdm72hJuBDCikHPizwI6eDCRyMTHqVlPTDtDMvGUfYsgThv7bjMJ8e4tjucVyNOe4EvGmznsueyaeI7dLPhYlThxa9XByK3XhXuSZuKfP1I9A4mRXnGPUoFMa6sJdy78/Ougags+NoZEXbckVpYSvyzR8rKs6XQChyZlRybltMP20Bnz3xtAK+iNOs5urPSULG+p6RXSuPYVICmuQWkQy+q4luNJ7w== kristian@doingit.no",
  ]

  authorized_cidr = [
    "0.0.0.0/0",
  ]

  tags {
    terraform   = "true"
    environment = "${var.env-name}"
  }
}