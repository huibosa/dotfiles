#!/usr/bin/env bash

alias powershell="/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/powershell.exe"
alias clip="/mnt/c/WINDOWS/System32/clip.exe"
alias code='/mnt/c/Users/huibo/AppData/Local/Programs/Microsoft\ VS\ Code/Code.exe'

open() {
    exp="/mnt/c/WINDOWS/explorer.exe"
    (
        cd "$1" || exit
        $exp .
    )
}

function mountusb() {
    # 1. Get input letter or default to 'e'
    local input=${1:-e}
    
    # 2. Standardize casing (works in Zsh & Bash)
    #    drive_lower -> for the linux path (e.g., /mnt/e)
    #    drive_upper -> for the windows drive (e.g., E:)
    local drive_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    local drive_upper=$(echo "$input" | tr '[:lower:]' '[:upper:]')
    
    local mount_point="/mnt/$drive_lower"

    # 3. Create folder if it doesn't exist
    if [ ! -d "$mount_point" ]; then
        echo "Creating mount point $mount_point..."
        sudo mkdir -p "$mount_point"
    fi

    # 4. Mount
    echo "Mounting ${drive_upper}: to $mount_point..."
    sudo mount -t drvfs "${drive_upper}:" "$mount_point"
}

function umountusb() {
    local input=${1:-e}
    local drive_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    local mount_point="/mnt/$drive_lower"

    echo "Unmounting $mount_point..."
    sudo umount "$mount_point"
}
