#!/usr/bin/env bash

find ./ \( -name '*.py' -o -name '*.sh' -o -name '*.cpp' -o -name '*.c' -o -name '*.go' -o -name '*.h' -o -name '*.md' \) -print0 |
	xargs -0 grep -Ev '^\s*$|^.{1}$' | wc -l
