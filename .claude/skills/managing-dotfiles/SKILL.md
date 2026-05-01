---
name: managing-dotfiles
description: "Track, untrack, and manage selective .gitignore patterns for a bare-repo dotfiles setup at ~/.dotfiles/. Use when: (1) User wants to track a new config file or directory, (2) User needs to untrack an existing file or directory, (3) User needs help with .gitignore patterns for selective tracking"
---

# Managing Dotfiles

Manage your dotfiles using a bare git repository at `~/.dotfiles/` with `$HOME` as the work-tree via the `dot` alias.

## Prerequisites

The bare repo at `~/.dotfiles/` and `dot` alias must be set up:
```bash
git init --bare "$HOME/.dotfiles"
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```
Both scripts validate this before running.

## Quick Reference

| Operation | Command |
|-----------|---------|
| Check status | `dot status` |
| Add file to tracking | `bash ~/.claude/skills/managing-dotfiles/scripts/add <path>` |
| Remove from tracking | `bash ~/.claude/skills/managing-dotfiles/scripts/remove <path>` |
| Commit changes | `dot commit -m "<message>"` |
| Push to remote | `dot push` |

## Scripts

### `scripts/add`

Adds a file or directory to tracking with automatic `.gitignore` pattern generation.

```bash
# Track a single file
bash ~/.claude/skills/managing-dotfiles/scripts/add ~/.zshrc

# Track a full directory
bash ~/.claude/skills/managing-dotfiles/scripts/add ~/.config/nvim/

# Dry run (show what would happen)
bash ~/.claude/skills/managing-dotfiles/scripts/add --dry-run ~/.config/nvim/

# Skip .gitignore auto-update
bash ~/.claude/skills/managing-dotfiles/scripts/add --no-gitignore ~/.zshrc
```

**What it does:**
1. Validates the path exists and bare repo is set up
2. Walks up the path to detect excluded ancestors and emits un-exclusion patterns
3. Auto-appends patterns to `~/.gitignore` (deduplicates existing entries)
4. Stages the target for tracking

### `scripts/remove`

Removes or untracks a file or directory.

```bash
# Untrack (keep on disk, default)
bash ~/.claude/skills/managing-dotfiles/scripts/remove ~/.config/unused/

# Hard remove (delete from disk too, requires confirmation)
bash ~/.claude/skills/managing-dotfiles/scripts/remove --hard ~/.config/temp/

# Dry run
bash ~/.claude/skills/managing-dotfiles/scripts/remove --dry-run --hard ~/.config/junk
```

**What it does:**
- `--soft` (default): Untracks from git index, auto-appends to `~/.gitignore` to prevent re-adding
- `--hard`: Removes from both git index and filesystem (requires typing `DELETE`)

## Verification Workflow

1. `dot status` — Check what changed
2. `dot diff --cached` — Review staged changes
3. `dot commit -m "message"` — Commit
4. `dot push` — Push to remote

## Troubleshooting

**File not showing in `dot status`**: Check if it's ignored in `.gitignore`. Use `git --git-dir=$HOME/.dotfiles --work-tree=$HOME check-ignore -v <path>` to trace why.

**Pattern not working**: See `references/gitignore-patterns.md` for the full pattern reference. Key rule: you must `!unignore` every parent directory.

**Changes not committing**: Ensure you ran `dot add <path>` before committing.
