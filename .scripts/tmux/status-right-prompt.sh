#!/bin/sh

mode=$1
path=$2
home=$HOME

display_path=$path
case "$path" in
    "$home")
        display_path='~'
        ;;
    "$home"/*)
        display_path="~${path#$home}"
        ;;
esac

branch=$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null || true)

case "$mode" in
    path)
        printf '%s' "$display_path"
        ;;
    branch)
        if [ -n "$branch" ]; then
            printf ':%s' "$branch"
        fi
        ;;
    *)
        if [ -n "$branch" ]; then
            printf '%s:%s' "$display_path" "$branch"
        else
            printf '%s' "$display_path"
        fi
        ;;
esac
