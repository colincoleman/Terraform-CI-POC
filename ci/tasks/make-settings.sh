#!/bin/sh
M2_HOME =${HOME}/.m2
mkdir -p ${M2_HOME}
M2_LOCAL_REPO="${ROOT_FOLDER}/.m2
mkdir -p "${M2_LOCAL_REPO}/repository"

cat > "settings/settings.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<settings>
	<servers>
        <server>
            <id>telia-iot-releases</id>
            <username>$nexusDeployUsername</username>
            <password>$nexusDeployPassword</password>
        </server>
        <server>
            <id>telia-iot-snapshots</id>
            <username>$nexusDeployUsername</username>
            <password>$nexusDeployPassword</password>
        </server>
	</servers>
	<localRepository>${M2_LOCAL_REPO}/repository</localRepository>
</settings>
EOF
echo "Settings xml written"