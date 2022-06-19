#!/usr/bin/env bash

ytdlp() {
  yt-dlp -o "%(title)s.%(ext)s" "$1"
}


lfcd () {
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
