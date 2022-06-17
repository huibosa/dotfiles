#!/usr/bin/env bash

yt-dlp() {
  command yt-dlp -o "%(title)s.%(ext)s" "$1"
}
