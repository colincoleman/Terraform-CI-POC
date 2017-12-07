#!/bin/sh
cd git-repo/terraform/env-dev
echo `pwd`
echo `ls`
terraform taint aws_ecs_task_definition.terraform-ci-poc