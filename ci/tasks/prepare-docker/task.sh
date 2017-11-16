#!/bin/sh
set -e
cp -p "jar-file/app.jar" git-repo/docker/toRoot/app.jar
echo "app.jar copied to docker workspace "
