#!/bin/sh
cd git-repo/terraform/env-dev
terraform init
/terraform taint aws_ecs_task_definition.terraform-ci-poc
terraform plan