#!/bin/sh

path=$1
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

last_dir=$(basename "$path")
show_branch=1
if [ -n "$branch" ]; then
    branch_as_dir=$(printf '%s' "$branch" | tr '/' '-')
    if [ "$last_dir" = "$branch_as_dir" ]; then
        show_branch=0
    fi
fi

blue='#[fg=blue,bright]'
yellow='#[fg=yellow,bright]'
dim='#[fg=colour245]'
reset='#[default]'

case "$display_path" in
    */.worktrees/*)
        before="${display_path%%/.worktrees/*}"
        after="${display_path#*/.worktrees/}"
        printf '%s%s%s//%s%s' "$blue" "$before" "$dim" "$blue" "$after"
        ;;
    *)
        printf '%s%s' "$blue" "$display_path"
        ;;
esac

if [ "$show_branch" = 1 ] && [ -n "$branch" ]; then
    printf '%s:%s' "$yellow" "$branch"
fi
