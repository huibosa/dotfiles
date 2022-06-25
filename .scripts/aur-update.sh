#!/usr/bin/env bash

function usage() {
	echo "Usage: $0 <package name>"
	exit 1
}

pack=
path="$HOME/Downloads"

case "$1" in
  chrome) pack="google-chrome" ;;
  code) pack="visual-studio-code-bin" ;;
  wezterm) pack="wezterm-nightly-bin" ;;
  *) usage ;;
esac

(
  cd "$path" || exit

  if [[ -n "$pack" && -e "$pack" ]]; then
    rm -rf "$pack"
  fi

  git clone --depth 1 "https://aur.archlinux.org/${pack}.git" &&
    cd "$path/$pack" &&
    yes | makepkg -si &&
    rm -rf $pack
)
