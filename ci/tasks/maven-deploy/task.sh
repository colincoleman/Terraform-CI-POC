#!/bin/sh
mvn -f "git-repo/pom.xml" --settings "settings/settings.xml" deploy
cp -p "$(ls -t git-repo/target/*.jar | grep -v /orig | head -1)" jar-file/app.jar
cp jar-file/app.jar git-repo/docker/toRoot/app.jar