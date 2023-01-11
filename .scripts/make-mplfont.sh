#!/usr/bin/env bash


# mplrcPath=$(echo 'import matplotlib; print(matplotlib.matplotlib_fname())' | python)
mplrcPath=$(python -c 'import matplotlib; print(matplotlib.matplotlib_fname())')

mplDataPath="${mplrcPath%/*}"

echo $mplrcPath
echo $mplDataPath

# cp "$@" mplDataPath="${mplrcPath%/*}/fonts/ttf/"
# rm -rf ~/.cache/matplotlib
