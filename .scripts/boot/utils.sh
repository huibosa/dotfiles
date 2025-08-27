#!/usr/bin/env bash

mirror() {
    wget -r -np -k "$1"
}

count-non-empty-line() {
    find ./ \( -name '*.py' -o -name '*.sh' -o -name '*.cpp' -o -name '*.c' -o -name '*.go' -o -name '*.h' -o -name '*.md' \) -print0 | xargs -0 grep -Ev '^\s*$|^.{1}$' | wc -l
}

sort-by-length() {
    awk '{ print length, $0 }' "$1" | sort -n -s | uniq | cut -d' ' -f2- > "./sorted-$(basename $1)"
}

ytdlp() {
    yt-dlp -o "%(title)s.%(ext)s" "$1"
}

# fy() {
#     cmd="fy"
#
#     if [ -x "$(command -v "$cmd")" ]; then
#         command "$cmd" "$@"
#     else
#         ssh arch "$cmd" "$@"
#     fi
# }

merge-zsh-history() {
    history1=$1
    history2=$2
    merged=$3

    echo "Merging history files: $history1 + $history2"

    test ! -f "$history1" && echo "File $history1 not found" && exit 1
    test ! -f "$history2" && echo "File $history2 not found" && exit 1

    cat "$history1" "$history2" | awk -v date="WILL_NOT_APPEAR$(date +"%s")" '{if (sub(/\\$/,date)) printf "%s", $0; else print $0}' | LC_ALL=C sort -u | awk -v date="WILL_NOT_APPEAR$(date +"%s")" '{gsub('date',"\\\n"); print $0}' > "$merged"

    echo "Merged to: $merged"
}

backup-root() {
    rsync -aAXSHv --delete --quiet --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/backup/*","/var/lib/dhcpcd/*","/home/*"} / /backup/root

    echo -e "$(date) (Root backup)" >> /tmp/backup.log
}

backup-home() {
    rsync -aAXHv --delete --quiet --exclude={"home/huibosa/.cache"} /home/huibosa /backup/home

    echo -e "$(date) (Home backup)" >> /tmp/backup.log
}

backup-wsl() {
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
}

make-mpl-font() {
    font_file="$1"

    # mplrcPath=$(echo 'import matplotlib; print(matplotlib.matplotlib_fname())' | python)
    mplrc=$(python -c 'import matplotlib; print(matplotlib.matplotlib_fname())')
    mpldata="${mplrc%/*}"
    mplcache=$(python -c 'import matplotlib; print(matplotlib.get_cachedir())')

    echo $mpldata
    echo $mplcache

    cp "$font_file" "${mpldata}/fonts/ttf/"
    rm -rf ~/.cache/matplotlib
}

md2docx() {
    local md
    local html

    converter="pandoc"
    if command -v wsl.exe &> /dev/null; then
        converter="pandoc.exe"
    fi

    md="$1"
    docx="${md%.*}.docx"
    $converter -f markdown "$1" -t docx -o "${docx}"
}

html2md() {
    local md
    local url

    converter="pandoc"
    if command -v wsl.exe &> /dev/null; then
        converter="pandoc.exe"
    fi

    url="$1"
    md="pandoc-markdown-output.md"
    $converter -f html "$url" -t commonmark-raw_html -o "${md}"
}

function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

lfcd() {
    local tmp
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp" &> /dev/null
        if [ -d "$dir" ]; then
            if [ "$dir" != "$(pwd)" ]; then
                cd "$dir" || exit
            fi
        fi
    fi
}
# Runs the specified command (provided by the first argument) in all tmux panes
# in every window.  If an application is currently running in a given pane
# (e.g., vim), it is suspended and then resumed so the command can be run.
tmux-all-panes() {
    _tmux-all-panes-bg "$1" &
}

# The actual implementation of `all-panes` that runs in a background process.
# This prevents the function from being suspended when we press ^z in each pane.
_tmux-all-panes-bg() {
    # Assign the argument to something readable
    local COMMAND="$1"
    local ORIG_WINDOW_INDEX
    local ORIG_PANE_INDEX
    local ORIG_PANE_SYNC

    # Remember which window/pane we were originally at
    ORIG_WINDOW_INDEX=$(tmux display-message -p '#I')
    ORIG_PANE_INDEX=$(tmux display-message -p '#P')

    # Loop through the windows
    for WINDOW in $(tmux list-windows -F '#I'); do
        # Select the window
        tmux select-window -t "$WINDOW"

        # Remember the window's current pane sync setting
        ORIG_PANE_SYNC=$(tmux show-window-options | grep '^synchronize-panes' | awk '{ print $2 }')

        # Send keystrokes to all panes within the current window simultaneously
        tmux set-window-option synchronize-panes on

        # Send the escape key in case we are in a vim-like program.  This is
        # repeated because the send-key command is not waiting for vim to complete
        # its action...  And sending a `sleep 1` command seems to screw up the loop.
        for _ in {1..25}; do tmux send-keys 'C-['; done

        # Temporarily suspend any GUI that's running
        tmux send-keys C-z

        # If no GUI was running, kill any input the user may have typed on the
        # command line to avoid A) concatenating our command with theirs, and
        # B) accidentally running a command the user didn't want to run
        # (e.g., rm -rf ~).
        tmux send-keys C-c

        # Run the command and switch back to the GUI if there was any
        tmux send-keys "$COMMAND; fg 2>/dev/null; echo -n" C-m

        # Restore the window's original pane sync setting
        if [[ -n "$ORIG_PANE_SYNC" ]]; then
            tmux set-window-option synchronize-panes "$ORIG_PANE_SYNC"
        else
            tmux set-window-option -u synchronize-panes
        fi
    done

    # Select the original window and pane
    tmux select-window -t "$ORIG_WINDOW_INDEX"
    tmux select-pane -t "$ORIG_PANE_INDEX"
}
