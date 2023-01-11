#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Recursively list descendants
listDescendants() {
  local children=$(ps -o pid= --ppid "$1")

  for pid in $children; do
    listDescendants "$pid"
  done

  echo "$children"
}

killAllChild() {
  kill $(listDescendants $$)
}

trap killAllChild SIGINT SIGTERM

for cmd in "$@"; do
  "${cmd}" &
  pids+=("$!")
done

wait
