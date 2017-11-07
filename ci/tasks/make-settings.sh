#!/bin/bash

M2_HOME="${HOME}/.m2"
M2_CACHE="${ROOT_FOLDER}/maven"

echo "Generating symbolic links for caches"

[[ -d "${M2_CACHE}" && ! -d "${M2_HOME}" ]] && ln -s "${M2_CACHE}" "${M2_HOME}"

echo "Writing maven settings to [${M2_HOME}/settings.xml]"

cat > "${M2_HOME}/settings.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<settings>
	<servers>
        <server>
            <id>telia-iot-releases</id>
            <username>$nexus-deploy-username</username>
            <password>$nexus-deploy-password</password>
        </server>
        <server>
            <id>telia-iot-snapshots</id>
            <username>$nexus-deploy-username</username>
            <password>$nexus-deploy-password</password>
        </server>
	</servers>
</settings>
EOF
echo "Settings xml written"
cat ${M2_HOME}/settings.xml