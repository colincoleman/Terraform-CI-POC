#!/bin/sh
set -e
cp -p -r git-repo/docker/ docker-folder
echo "resources copied to docker workspace "
echo `ls`
cp jar-file/app.jar docker-folder/toRoot/app.jar
echo "app.jar copied to docker workspace "
