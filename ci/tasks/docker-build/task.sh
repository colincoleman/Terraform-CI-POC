#!/bin/sh
#set -e
cp -p "jar-file/app.jar" git-repo/docker/app.jar
echo `pwd`
echo "hello"
cd git-repo/docker
echo `pwd`
docker build -t terraform-ci-poc .
#docker push 752583717420.dkr.ecr.eu-west-1.amazonaws.com/terraform-ci-poc:latest
