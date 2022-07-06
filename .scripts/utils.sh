#!/usr/bin/env bash

ytdlp() {
  yt-dlp -o "%(title)s.%(ext)s" "$1"
}


lfcd () {
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
  all-panes-bg_ "$1" &
}

# The actual implementation of `all-panes` that runs in a background process.
# This prevents the function from being suspended when we press ^z in each pane.
tmux-all-panes-bg_() {
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
