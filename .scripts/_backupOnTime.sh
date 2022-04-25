#!/bin/bash

today="$(date +%Y-%m-%d)"
monthBack="$(date --date="a month ago" +%Y-%m-%d)"

rsync -aAXHv --delete --quiet --exclude={"/home/huibosa/.cache/*"} $HOME $BACKUP/home/$today
echo -e "$(date) (Home backup)" >> /tmp/backup.log

if [[ -e $BACKUP/home/$monthBack ]]; then
  rm -rf $BACKUP/home/$monthBack
  echo -e "$(date) (Remove backup)" >> /tmp/backup.log
fi
