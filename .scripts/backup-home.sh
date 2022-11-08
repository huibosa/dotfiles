#!/bin/bash

rsync -aAXHv --delete --quiet --exclude={"home/huibosa/.cache"} /home/huibosa /backup/home

echo -e "$(date) (Home backup)" >>/tmp/backup.log
