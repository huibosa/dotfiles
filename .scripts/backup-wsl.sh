#!/usr/bin/env bash

# This backup script make a local and remote disk backup separately

DEST1="/home/$USER/winhome/backup/${WSL_DISTRO_NAME}"
DEST2="/mnt/d/backup/${WSL_DISTRO_NAME}"
LOGFILE1="/home/$USER/winhome/backup/${WSL_DISTRO_NAME}.log"
LOGFILE2="/mnt/d/backup/${WSL_DISTRO_NAME}.log"

if [ ! -e "/home/$USER/winhome/" ]; then
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

    mkdir -p "/home/$USER/winhome/backup/${WSL_DISTRO_NAME}/"
    time rsync -rltD --delete --verbose --exclude '.cache/*' "/home/$USER/" "$DEST1"
    echo
    echo "=====> " "$(date '+%F %T')" "FINISHED" "${WSL_DISTRO_NAME}"
    echo

} 2>&1 | tee "${LOGFILE1}"

# Check if a removeable disk connected
if [[ -d /mnt/d/backup ]]; then
{
    echo "=====>"
    echo "=====> Starting ${WSL_DISTRO_NAME} Backup"
    echo "=====> " "$(date '+%F %T')"
    echo "=====>"

    echo
    echo "==> Syncing files <=="
    echo

    mkdir -p "$DEST2"
    time rsync -rltD --delete --verbose --exclude '.cache/*' "/home/$USER/" "$DEST2"
    echo
    echo "=====> " "$(date '+%F %T')" "FINISHED" "${WSL_DISTRO_NAME}"
    echo

} 2>&1 | tee "${LOGFILE2}"
fi
