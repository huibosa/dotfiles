#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  local scriptName
  scriptName=$(basename "$0")
	echo "Usage: $scriptName [*.py || *.ipynb]"
}

pyToIpynb() {
	jupytext --to notebook "$@"
}

ipynbToPy() {
	jupytext --set-formats ipynb,py "$@"
}

update() {
	[[ "$1" == *.ipynb ]] && ipynbToPy "$1"
	[[ "$1" == *.py ]] && pyToIpynb "$1"
}

getRival() {
	[[ $# -ne 1 ]] && echo "${FUNCNAME[0]}: Wrong argument count" && exit 1
	if [[ "$1" == *.ipynb ]]; then
		echo "${fname/%.ipynb/.py}"
	elif [[ "$1" == *.py ]]; then
		echo "${fname/%.py/.ipynb}"
	else
		echo "${FUNCNAME[0]}: Wrong file format"
		exit 1
	fi
}

updateAll() {
	read -r -p "To convert all jupyter file recursively type \"CONVERT\": "
	[[ "$REPLY" != "CONVERT" ]] && exit 0

	readarray -d '' fnames < <(find ./ -type f \( -name '*.py' -o -name '*.ipynb' \) -print0)

	for fname in "${fnames[@]}"; do
		rival="$(getRival "$fname")"

		if [[ -f "$rival" ]]; then
			if [[ "$fname" -nt "$rival" ]]; then
				update "$fname"
			elif [[ "$rival" -nt "$fname" ]]; then
				update "$rival"
			fi
		else
			update "$fname"
		fi
	done
}

# if ! command -v jupytext &> /dev/null ; then
#   echo "jupytext not installed, installing use pip..."
#   pip install jupytext
# fi

if [[ $# -eq 0 ]]; then
	updateAll
elif [[ "$1" == *.ipynb ]]; then
	jupytext --set-formats ipynb,py "$@"
elif [[ "$1" == *.py ]]; then
	jupytext --to notebook "$@"
else
	usage
fi
