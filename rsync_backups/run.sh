#!/bin/bash
set -e

echo "[Info] Starting Hass.io rsync-backups docker container!"

CONFIG_PATH=/data/options.json
server=$(jq --raw-output ".server" $CONFIG_PATH)
port=$(jq --raw-output ".port" $CONFIG_PATH)
directory=$(jq --raw-output ".directory" $CONFIG_PATH)
username=$(jq --raw-output ".username" $CONFIG_PATH)
password=$(jq --raw-output ".password" $CONFIG_PATH)
auto_purge=$(jq --raw-output ".auto_purge" $CONFIG_PATH)

rsyncurl="$username@$server:$directory"

echo "[Info] Start rsync-backups"

echo "[Info] Start rsync backups to $rsyncurl"
sshpass -p $password rsync -av -e "ssh -p $port -o StrictHostKeyChecking=no" /backup/ $rsyncurl

if [ $auto_purge -ge 1 ]; then
	echo "[Info] Start auto purge, keep last $auto_purge backups"
	rm `ls -t /backup/*.tar | awk "NR>$auto_purge"`
fi

echo "[Info] Finished rsync-backups"
