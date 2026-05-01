# Gitignore Patterns Reference

Canonical reference for `.gitignore` patterns in a bare-repo dotfiles setup.
For troubleshooting, see SKILL.md.

## The Core Rule

Gitignore uses exclusion + inclusion patterns:
- `dir/` excludes a directory and everything under it
- `dir/*` excludes contents but not the directory itself
- `!path` re-includes (un-excludes) a path
- Order matters — git processes patterns top-to-bottom, first match wins

## Pattern Syntax

| Pattern | Meaning |
|---------|---------|
| `file.txt` | Exclude file.txt in this directory |
| `dir/` | Exclude entire directory and contents |
| `dir/*` | Exclude contents of dir (dir itself not excluded) |
| `!dir/file.txt` | Re-include specific file |
| `**/file.txt` | Exclude file.txt anywhere in tree |

## Parent Directory Rule

To un-exclude a nested path, you **must** un-exclude every ancestor that's excluded:

```gitignore
# To track .config/lf/something:
.config/lf/              # Exclude the directory
!.config/lf/             # Un-exclude the directory itself
!.config/lf/*            # Un-exclude all contents
!.config/lf/something    # Un-exclude the specific item
```

The `add` script handles this automatically by walking up the path.

## Common Patterns

| Goal | Pattern |
|------|---------|
| Track single file | `!.path/to/file` |
| Track full directory | `!.path/to/dir/` + `!.path/to/dir/*` |
| Track nested dir only | Exclude parent with `/*`, then `!` the target |
| Ignore file | Add to .gitignore without `!` |
| Ignore directory contents | `dir/*` (keeps dir, ignores contents) |
| Ignore directory entirely | `dir/` |

## Examples

### Single file
```gitignore
!.zshrc
```

### Directory with all contents
```gitignore
!.config/nvim/
!.config/nvim/*
```

### Selective subdirectory tracking
Track `.config/lf/` but exclude everything else in `.config/`:
```gitignore
.config/*
!.config/lf/
!.config/lf/*
```

### Multiple selective subdirs
```gitignore
.config/*
!.config/lf/
!.config/lf/*
!.config/yazi/
!.config/yazi/*
```

## Debugging

```bash
# Trace why a path is ignored
git --git-dir=$HOME/.dotfiles --work-tree=$HOME check-ignore -v <path>
```
