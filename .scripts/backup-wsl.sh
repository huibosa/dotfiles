#!/usr/bin/env bash

# This backup script make a local and remote disk backup separately
if [ "$EUID" -eq 0 ]; then
  WSL_DISTRO_NAME="Arch"
fi

DEST1="/home/huibo/winhome/backup/${WSL_DISTRO_NAME}"
DEST2="/mnt/d/backup/${WSL_DISTRO_NAME}"
LOGFILE1="/home/huibo/winhome/backup/${WSL_DISTRO_NAME}.log"
LOGFILE2="/mnt/d/backup/${WSL_DISTRO_NAME}.log"

if [ ! -e "/home/huibo/winhome/" ]; then
    echo "ERROR: ~/winhome/ is broken, cannot backup ${WSL_DISTRO_NAME}" | tee -a "$LOGFILE1"
    exit
fi

{
    echo "=====>"
    echo "=====> Starting ${WSL_DISTRO_NAME} Backup"
    echo "=====> " "$(date '+%F %T')"
    echo "=====>"

    echo
    echo "==> Syncing files <=="
    echo

    [ -d "${DEST1}" ] || mkdir -p "${DEST1}"
    time rsync -rltD --delete --verbose --exclude '.cache/*' "/home/huibo/" "${DEST1}"
    echo
    echo "=====> " "$(date '+%F %T')" "FINISHED" "${WSL_DISTRO_NAME}"
    echo

} 2>&1 | tee "${LOGFILE1}"

# Check if a removeable disk connected
if [ -d /mnt/d/backup ]; then
{
    echo "=====>"
    echo "=====> Starting ${WSL_DISTRO_NAME} Backup"
    echo "=====> " "$(date '+%F %T')"
    echo "=====>"

    echo
    echo "==> Syncing files <=="
    echo

    [ -d "${DEST2}" ] || mkdir -p "${DEST2}"
    time rsync -rltD --delete --verbose --exclude '.cache/*' "/home/huibo/" "${DEST2}"
    echo
    echo "=====> " "$(date '+%F %T')" "FINISHED" "${WSL_DISTRO_NAME}"
    echo

} 2>&1 | tee "${LOGFILE2}"
fi
