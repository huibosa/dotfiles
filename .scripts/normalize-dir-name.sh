#!/usr/bin/env bash

renameBin=perl-rename

if uname -a | grep -qEi "(microsoft|wsl)" &> /dev/null ; then
  renameBin=rename
fi

find ./ -print0 | while IFS= read -rd fname; do
  # fname="${fname##*/}"
  "$renameBin" -v 'y/_/-/' "$fname"
done

find ./ -print0 | while IFS= read -rd fname; do
  # fname="${fname##*/}"
  "$renameBin" -v 'y/[A-Z]/[a-z]/' "$fname"
done
