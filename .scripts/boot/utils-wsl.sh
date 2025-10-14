#!/usr/bin/env bash

alias powershell="/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/powershell.exe"
alias clip="/mnt/c/WINDOWS/System32/clip.exe"

open() {
    exp="/mnt/c/WINDOWS/explorer.exe"
    (
        cd "$1" || exit
        $exp .
    )
}

mount-win-disk() {
    if [ ! -d "$1" ]; then
        sudo mkdir /mnt/"$1"
    fi

    sudo mount -t drvfs "$1": /mnt/"$1"
}

umount-win-disk() {
    sudo umount "/mnt/$1"
}
