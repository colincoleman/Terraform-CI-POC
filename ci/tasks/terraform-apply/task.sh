#!/bin/sh
cd git-repo/terraform/env-dev
terraform init
teraform plan
#terraform apply