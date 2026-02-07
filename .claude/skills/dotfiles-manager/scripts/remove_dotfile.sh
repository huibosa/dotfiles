#!/usr/bin/env bash
# Remove or untrack a file/directory from dotfiles tracking

set -e

usage() {
	echo "Usage: $(basename "$0") [OPTIONS] <path>"
	echo ""
	echo "Options:"
	echo "  --soft    Untrack from git index (keeps file locally, default)"
	echo "  --hard    Remove from both git index and working directory"
	echo "  --purge   Untrack, remove from index, and delete from filesystem"
	echo ""
	echo "Examples:"
	echo "  $(basename "$0") --soft ~/.config/unused/"
	echo "  $(basename "$0") --hard ~/.config/temp/"
	echo "  $(basename "$0") --purge ~/.config/junk"
	exit 1
}

die() {
	echo "Error: $1" >&2
	exit 1
}

MODE="soft"

# Parse arguments
while [[ $# -gt 0 ]]; do
	case "$1" in
	--soft | --hard | --purge)
		MODE="${1#--}"
		shift
		;;
	-*)
		die "Unknown option: $1"
		;;
	*)
		break
		;;
	esac
done

[[ $# -lt 1 ]] && usage
PATH="$1"
shift

# Resolve to absolute path
ABS_PATH=$(realpath "$PATH" 2>/dev/null) || ABS_PATH="$PATH"

# Get relative path from $HOME
REL_PATH="${ABS_PATH#$HOME/}"

echo "=== Dotfiles Remove ==="
echo "Path: $ABS_PATH"
echo "Relative: $REL_PATH"
echo "Mode: $MODE"
echo ""

# Check if tracked
if ! git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" ls-files --error-unmatch "$REL_PATH" 2>/dev/null; then
	echo "Not tracked in dotfiles."
	exit 0
fi

case "$MODE" in
soft)
	echo "=== Untracking (soft remove) ==="
	echo "File will remain on disk but stop being tracked."
	git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" rm -r --cached "$REL_PATH"
	echo ""
	echo "To prevent re-adding, add to ~/.gitignore:"
	echo "  $REL_PATH"
	echo ""
	echo "Run:"
	echo "  dot add ~/.gitignore"
	echo "  dot commit -m \"untrack $REL_PATH\""
	;;
hard)
	echo "=== Removing (hard remove) ==="
	echo "File will be removed from both git index AND filesystem."
	read -p "Continue? [y/N] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" rm -r "$REL_PATH"
		echo ""
		echo "Run:"
		echo "  dot commit -m \"remove $REL_PATH\""
	else
		echo "Cancelled."
	fi
	;;
purge)
	echo "=== Purging ==="
	echo "This will: untrack, remove from index, AND delete from filesystem."
	echo "This action CANNOT be undone."
	read -p "Type DELETE to confirm: " -r
	echo
	if [[ "$REPLY" == "DELETE" ]]; then
		git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" rm -r --cached "$REL_PATH" 2>/dev/null || true
		rm -rf "$ABS_PATH"
		echo ""
		echo "Run:"
		echo "  dot commit -m \"purge $REL_PATH\""
	else
		echo "Cancelled."
	fi
	;;
esac
