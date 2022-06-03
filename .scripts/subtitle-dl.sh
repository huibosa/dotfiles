#!/usr/bin/env bash

usage() {
  printf "Usage: %s [url]\n" "$0"
  exit 1
}

writeSubs() {
  [ ! -e subs ] && mkdir subs
  # Execute in subshell to avoid cd back
  (
    cd subs || exit

    printf "Downloading subtitles...\n"
    yt-dlp --write-subs --skip-download --sub-lang=en -o "%(title)s.%(ext)s" "$1"

    convertSubs
    clean
  )
}

writeAutoSubs() {
  [ ! -e auto-subs ] && mkdir auto-subs
  # Execute in subshell to avoid cd back
  (
    cd auto-subs || exit

    printf "Downloading auto-generated subtitles...\n"
    yt-dlp --write-auto-subs --skip-download --sub-lang=en -o "%(title)s.%(ext)s" "$1"

    convertSubs
    clean
  )
}

# Convert format from vtt to ass
convertSubs() {
  for fname in *; do
    if [[ "$fname" == *.vtt ]]; then
      ffmpeg -i "$fname" "${fname%vtt}ass" &> /dev/null
    fi
  done
}

mergeSubs() {
  # Get subtitles
  cp subs/* ./

  # Get subtitles only in auto-sub
  while read -r line; do
    file=$(echo "$line" | cut -d' ' -f4-)
    cp auto-subs/"$file" .
  done < <(diff -q auto-subs subs | grep 'Only')

  # IFS=':' read -a fnames < <(diff -q ./auto-subs ./subs | grep 'Only' | cut -d' ' -f4- | tr '\n' ':')
  # for fname in "${fnames[@]}"; do
  #   cp auto-subs/"$fname" .
  # done
}

clean() {
  rm -rf ./*.vtt
}

if [[ $# == 0 ]]; then
  usage
fi

writeSubs "$1"
writeAutoSubs "$1"
mergeSubs
