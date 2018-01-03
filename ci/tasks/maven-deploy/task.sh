#!/bin/sh
M2_LOCAL_REPO=".m2"
mkdir -p "${M2_LOCAL_REPO}/repository"
echo `ls -al .m2/`
mvn -f "git-repo/pom.xml" --settings "settings/settings.xml" deploy
echo `ls -al .m2/repository/`

cp -p "$(ls -t git-repo/target/*.jar | grep -v /orig | head -1)" jar-file/app.jar
