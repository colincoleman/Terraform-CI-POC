#!/bin/sh
mvn -f "git-repo/pom.xml" --settings "settings/settings.xml" deploy
cp -p "git-repo/target/$(ls -t git-repo/target/*.jar | grep -v /orig | head -1)" app.jar