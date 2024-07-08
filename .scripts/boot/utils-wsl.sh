#!/usr/bin/env bash

open() {
    (
        cd "$1" || exit
        explorer.exe .
    )
}

mount-win-disk() {
    if ![ -d "$1" ]; then
        mkdir /mnt/"$1"
    fi

    mount -t drvfs "$1": /mnt/"$1"
}

umount-win-disk() {
    umount "/mnt/$1"
}
