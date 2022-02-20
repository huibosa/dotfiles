#!/usr/bin/env bash


find ./ | while read -r fname; do
  perl-rename -i 'y/_/-/' "$fname"
  perl-rename -i 'y/[A-Z]/[a-z]/' "$fname"
done

