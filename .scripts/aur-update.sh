#!/usr/bin/env bash

function usage() {
	"Usage: $0 [package name]"
	exit 1
}

oldPath=$(pwd)
pack=
path="$HOME/Downloads"

case "$1" in
chrome) pack="google-chrome" ;;
code) pack="visual-studio-code-bin" ;;
*) usage ;;
esac

cd $path

if [[ -n "$pack" && -e "$pack" ]]; then
	rm -rf "$pack"
fi

git clone --depth 1 "https://aur.archlinux.org/${pack}.git" &&
	cd "$path/$pack" &&
	yes | makepkg -si &&
	cd .. &&
	rm -rf $pack

cd "$oldPath"
