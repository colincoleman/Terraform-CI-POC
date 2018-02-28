data "terraform_remote_state" "workshop-common-infrastructure" {
  backend = "s3"

  config {
    bucket     = "${var.workshop-common-infrastructure-remote_state_bucket}"
    region     = "${var.workshop-common-infrastructure-remote_state_region}"
    key        = "${var.workshop-common-infrastructure-remote_state_key}"
    kms_key_id = "${var.workshop-common-infrastructure-remote_state_kms_key_id}}"
  }
}

module "lb" {
  source     = "github.com/TeliaSoneraNorge/divx-terraform-modules//ec2/lb?ref=0.3.4"
  prefix     = "${var.env-name}-${var.project-name}"
  type       = "application"
  internal   = "false"
  vpc_id     = "${data.terraform_remote_state.workshop-common-infrastructure.vpc_id}"
  subnet_ids = ["${data.terraform_remote_state.workshop-common-infrastructure.vpc_public_subnet_ids}"]
  tags       = "${var.tags}"
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
  source         = "github.com/TeliaSoneraNorge/divx-terraform-modules//container/cluster"
  prefix         = "${var.env-name}-${var.project-name}"
  vpc_id         = "${data.terraform_remote_state.workshop-common-infrastructure.vpc_id}"
  subnet_ids     = ["${data.terraform_remote_state.workshop-common-infrastructure.vpc_private_subnet_ids}"]
  ingress_length = 1

  ingress {
    "0" = "${module.lb.security_group_id}"
  }

  tags           = "${var.tags}"
  instance_type  = "${var.cluster_instance_type}"
  instance_count = "${var.cluster_instance_count}"
}

resource "aws_cloudwatch_log_group" "main" {
  name = "${var.project-name}-${var.env-name}"
}

resource "aws_ecs_task_definition" "terraform-ci-poc" {
  family = "${var.project-name}"

  container_definitions = <<EOF
[
  {
    "name": "${var.env-name}-${var.project-name}",
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
        "awslogs-region": "eu-west-1"
      }
    }
  }
]
EOF
}

module "terraform-ci-service" {
  source = "github.com/TeliaSoneraNorge/divx-terraform-modules//container/service"

  prefix             = "${var.env-name}-${var.project-name}"
  cluster_id         = "${module.cluster.id}"
  cluster_role       = "${module.cluster.role_id}"
  task_definition    = "${aws_ecs_task_definition.terraform-ci-poc.arn}"
  task_log_group_arn = "${aws_cloudwatch_log_group.main.arn}"
  container_count    = "2"

  load_balancer {
    target_group_arn = "${module.targetHTTP.target_group_arn}"
    container_name   = "${var.env-name}-${var.project-name}"
    container_port   = "${module.targetHTTP.container_port}"
  }

  tags = "${var.tags}"
}

module "targetHTTP" {
  source = "github.com/TeliaSoneraNorge/divx-terraform-modules//container/target"

  prefix            = "${var.project-name}"
  vpc_id            = "${data.terraform_remote_state.workshop-common-infrastructure.vpc_id}"
  load_balancer_arn = "${module.lb.arn}"

  target {
    protocol = "HTTP"
    port     = "5050"
    health   = "HTTP:traffic-port/"
  }

  listeners = [{
    protocol = "HTTP"
    port     = "80"
  }]

  tags = "${var.tags}"
}

resource "aws_key_pair" "ssh_key_for_cluster" {
  key_name   = "${var.env-name}-${var.project-name}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDgc2VhScUhekS3WYe1gF54W0Z0Hs0LZrpRopaEMdUmGkIIdlIMzUh/BVckneEtzy8nigkpoeEWf2n+kqFmYSlfUk5AvQZ9EIgwLuitjxqpCplOZQVB9TcMn2G3DLeb1VGl7YjvnsPZqQvS9ZHPO1j1+G5QNh12Bf8AjJlkfwxnza+zAeGac8mtncSTRcvoD0WxZ366VGOG2Lz+e5uLduxnDloxDF5QiAOsvrEnISVfCh33fYD//QhyqFwXqEVNmQq8iTEaU5ikRMIXikFssVygouGyhSl5BiQrwIuFn9eBMraSZCsgA0IM27sptN7cGVvkj9EkkPi3ewiW+JZu3jVx"
}

module "bastion" {
  source     = "github.com/TeliaSoneraNorge/divx-terraform-modules//bastion?ref=0.3.4"
  prefix     = "${var.env-name}-${var.project-name}"
  vpc_id     = "${data.terraform_remote_state.workshop-common-infrastructure.vpc_id}"
  subnet_ids = "${data.terraform_remote_state.workshop-common-infrastructure.vpc_public_subnet_ids}"
  pem_bucket = "tn-lab-config"
  pem_path   = "${var.env-name}-${var.project-name}.pem"

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
