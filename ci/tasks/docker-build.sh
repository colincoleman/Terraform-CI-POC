#!/bin/sh
set -e
cd ../../docker
cp -p "../target/$(ls -t ../target/*.jar | grep -v /orig | head -1)" app.jar

docker build -t terraform-ci-poc .

docker.withRegistry('https://752583717420.dkr.ecr.eu-west-1.amazonaws.com','ecr:eu-west-1:aws-deploy') {
        docker.image('terraform-ci-poc').push('latest')