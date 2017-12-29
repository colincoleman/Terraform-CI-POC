#!/bin/sh
cat > "settings/settings.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<settings>
	<servers>
        <server>
            <id>telia-iot-releases</id>
            <username>$nexusSnapshotDeployUsername</username>
            <password>$nexusShapshotDeployPassword</password>
        </server>
        <server>
            <id>telia-iot-snapshots</id>
            <username>$nexusSnapshotDeployUsername</username>
            <password>$nexusShapshotDeployPassword</password>
        </server>
	</servers>
	<localRepository>${M2_LOCAL_REPO}/repository</localRepository>
</settings>
EOF
echo "Settings xml written"