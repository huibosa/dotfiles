#!/usr/bin/env bash
# Add a file or directory to dotfiles tracking with automatic .gitignore pattern generation

set -e

usage() {
	echo "Usage: $(basename "$0") <path>"
	echo "  <path>  File or directory to add to dotfiles tracking"
	echo ""
	echo "This script:"
	echo "  1. Validates the path exists"
	echo "  2. Generates correct .gitignore patterns"
	echo "  3. Stages the file for tracking"
	echo "  4. Outputs the commit command"
	exit 1
}

die() {
	echo "Error: $1" >&2
	exit 1
}

# Check arguments
[[ $# -lt 1 ]] && usage
PATH="$1"
shift

# Resolve to absolute path
ABS_PATH=$(realpath "$PATH" 2>/dev/null) || ABS_PATH="$PATH"

# Check if path exists
[[ ! -e "$ABS_PATH" ]] && die "Path does not exist: $PATH"

# Get relative path from $HOME
REL_PATH="${ABS_PATH#$HOME/}"

# Determine if file or directory
if [[ -d "$ABS_PATH" ]]; then
	TYPE="directory"
else
	TYPE="file"
fi

echo "=== Adding to Dotfiles ==="
echo "Path: $ABS_PATH"
echo "Type: $TYPE"
echo "Relative: $REL_PATH"
echo ""

# Check if already tracked
if git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" ls-files --error-unmatch "$REL_PATH" 2>/dev/null; then
	echo "Already tracked in dotfiles."
	exit 0
fi

# Generate .gitignore patterns
echo "=== Suggested .gitignore Entry ==="
if [[ "$TYPE" == "file" ]]; then
	echo "!$REL_PATH"
else
	echo "!$(dirname "$REL_PATH")/"
	echo "!$(dirname "$REL_PATH")/*"
	echo "!$REL_PATH"
	echo "!$REL_PATH/*"
fi

echo ""
echo "=== Staging ==="
git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" add "$REL_PATH"

echo "File staged. Run:"
echo "  dot commit -m \"add $REL_PATH\""
