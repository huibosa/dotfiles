#!/usr/bin/env bash
# all *.go file in current dir to a separate file

dirName=""

toDir() {
  if [[ -e "$dirName" ]]; then
    echo "Warning: directory <$dirName> already exist! Exiting..."
    exit 1
  else
    mkdir "$dirName" && mv "$1" "$dirName"
  fi
}

for f in *; do
  dirName="${f%.*}"
  toDir "$f"
done
