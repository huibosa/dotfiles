#!/usr/bin/env bash

font_file="$1"

# mplrcPath=$(echo 'import matplotlib; print(matplotlib.matplotlib_fname())' | python)
mplrc=$(python -c 'import matplotlib; print(matplotlib.matplotlib_fname())')
mpldata="${mplrc%/*}"
mplcache=$(python -c 'import matplotlib; print(matplotlib.get_cachedir())')

echo $mpldata
echo $mplcache

cp "$font_file" "${mpldata}/fonts/ttf/"
rm -rf ~/.cache/matplotlib
