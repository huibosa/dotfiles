#!/bin/bash

rsync -aAXSHv --delete --quiet --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/backup/*","/var/lib/dhcpcd/*","/home/*"} / /backup/root

echo -e "$(date) (Root backup)" >>/tmp/backup.log
