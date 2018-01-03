#!/bin/sh
cd git-repo/terraform/env-dev
terraform init -input=false
terraform taint aws_ecs_task_definition.terraform-ci-poc
terraform apply -auto-approve