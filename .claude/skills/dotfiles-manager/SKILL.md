---
name: dotfiles-manager
description: Add, remove, and manage dotfiles in your bare git repository at ~/.dotfiles/. Use when: (1) User wants to track a new config file or directory, (2) User needs to untrack an existing file or directory, (3) User needs help with .gitignore patterns for selective tracking
---

# Dotfiles Manager

Manage your dotfiles using a bare git repository at `~/.dotfiles/` with `$HOME` as the work-tree via the `dot` alias.

## Quick Reference

| Operation | Command |
|-----------|---------|
| Check status | `dot status` |
| Add file to tracking | `dot add <path>` |
| Commit changes | `dot commit -m "<message>"` |
| Push to remote | `dot push` |

## Adding Files to Tracking

### Single File
```bash
dot add ~/.zshrc
dot commit -m "add zshrc"
```

### Full Directory
```bash
dot add ~/.config/nvim/
dot commit -m "add neovim config"
```

### Selective Subdirectory Tracking
For directories where you only want specific subfolders tracked:
```bash
# In ~/.gitignore, use this pattern:
.config/lf/
!.config/lf/*
```
This excludes all of `.config/lf/` then re-includes everything inside it.

## Removing Files from Tracking

### Option 1: Untrack (keeps file locally)
```bash
dot rm -r --cached <path>
# Update .gitignore to prevent re-adding
dot add ~/.gitignore
dot commit -m "untrack <path>"
```

### Option 2: Remove Completely
```bash
dot rm -r <path>
dot commit -m "remove <path>"
```

## Verification Workflow

1. `dot status` - Check what changed
2. `dot diff --cached` - Review staged changes
3. `dot commit -m "message"` - Commit
4. `dot push` - Push to remote

## Troubleshooting

**File not showing in `dot status`**: Check if it's ignored in `.gitignore`

**Pattern not working**: Remember - you must `!unignore` every parent directory. For example, to track `.config/lf/something`:
```
.config/lf/
!.config/lf/
!.config/lf/*
!.config/lf/something
```

**Changes not committing**: Ensure you ran `dot add <path>` before committing.

## Scripts

- `scripts/add_dotfile.sh` - Automated add with .gitignore pattern generation
- `scripts/remove_dotfile.sh` - Safe removal with --soft/--hard/--purge options

Run scripts from the skill directory: `bash ~/.claude/skills/dotfiles-manager/scripts/<script>.sh <args>`
