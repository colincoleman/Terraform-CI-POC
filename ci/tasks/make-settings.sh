#!/bin/sh
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
</settings>
EOF
echo "Settings xml written"
cat settings/settings.xml