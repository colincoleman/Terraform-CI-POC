#!/bin/sh
cd git-repo/terraform/env-dev
echo $AWS_ACCESS_KEY_ID
terraform init
#terraform taint aws_ecs_task_definition.terraform-ci-poc