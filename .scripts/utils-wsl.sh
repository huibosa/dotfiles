#!/usr/bin/env bash

open() {
  (
    cd "$1" || exit
    explorer.exe .
  )
}

mount-win-disk () {
  sudo mount -t drvfs "$1": /mnt/"$1"
}

umount-win-disk () {
  sudo umount "/mnt/$1"
}
