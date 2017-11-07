#!/bin/bash
cat > "settings.xml" <<EOF
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
cat settings.xml