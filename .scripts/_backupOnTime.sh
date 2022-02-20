#!/bin/bash
# backup the home directory every three days

backupFile="$(date +%Y-%m-%d)"
rmFile="$(date --date="a weeks ago" +%Y-%m-%d)"
echo ${rmFile}

# rsync -aAXHv --delete --quiet --exclude={"/home/huibosa/.cache/*"} /home/huibosa /backup/home/
