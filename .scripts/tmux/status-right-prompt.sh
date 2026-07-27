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

# Linked worktree (e.g. .claude/worktrees/<name>): the deep path is mostly
# noise — show just "<repo>:<branch>". A linked worktree's git-dir differs
# from the common git-dir; the repo name is the common dir's parent.
git_dir=$(git -C "$path" rev-parse --git-dir 2>/dev/null || true)
common_dir=$(git -C "$path" rev-parse --git-common-dir 2>/dev/null || true)
if [ -n "$git_dir" ] && [ -n "$common_dir" ] && [ "$git_dir" != "$common_dir" ]; then
    case "$common_dir" in
        /*) abs_common="$common_dir" ;;
        *)  abs_common="$path/$common_dir" ;;
    esac
    repo_root=$(cd "$abs_common" 2>/dev/null && cd .. && pwd) || repo_root=""
    repo_name=${repo_root##*/}
    [ -z "$repo_name" ] && repo_name="?"
    printf '%s%s' "$blue" "$repo_name"
    if [ -n "$branch" ]; then
        printf '%s:%s' "$yellow" "$branch"
    fi
    exit 0
fi

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
