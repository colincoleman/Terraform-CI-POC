#!/bin/sh
set -e
cp -p -r git-repo/docker/ docker-folder
echo "resources copies to docker workspace "
cp -p "jar-file/app.jar" docker-folder/toRoot/app.jar
echo "app.jar copied to docker workspace "
