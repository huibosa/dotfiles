# Gitignore Patterns Reference

## The Core Rule

Gitignore uses exclusion + inclusion patterns:
- `dir/` excludes a directory and everything under it
- `dir/*` excludes contents but not the directory itself
- `!path` re-includes (un-excludes) a path

## Pattern Syntax

| Pattern | Meaning |
|---------|---------|
| `file.txt` | Exclude file.txt in this directory |
| `dir/` | Exclude entire directory and contents |
| `dir/*` | Exclude contents of dir (dir itself not excluded) |
| `!dir/file.txt` | Re-include specific file |
| `**/file.txt` | Exclude file.txt anywhere in tree |

## Selective Subdirectory Tracking

To track `.config/lf/` but exclude everything else in `.config/`:

```gitignore
.config/*
!.config/lf/
!.config/lf/*
```

The order matters! Git processes patterns in order.

## Common Patterns

### Single file
```gitignore
!.zshrc
```

### Directory with all contents
```gitignore
!.config/nvim/
!.config/nvim/*
```

### Nested selective tracking
To track `.config/lf/` and its subdirs:
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

## Parent Directory Rule

To un-exclude anything, you must un-exclude every parent:

```
# To track .config/lf/something:
.config/lf/              # Exclude the directory
!.config/lf/             # Un-exclude the directory itself
!.config/lf/*            # Un-exclude all contents
!.config/lf/something    # Un-exclude the specific item
```

## Troubleshooting

**Pattern not working?**
1. Check order - earlier patterns win
2. Ensure parent directories are un-excluded
3. Run `git check-ignore -v <path>` to see why a path is ignored

**File shows as untracked but you want it ignored:**
```bash
echo "path/to/file" >> ~/.gitignore
```

**File is tracked but you want to untrack:**
```bash
dot rm -r --cached path/to/file
# Then add exclusion to .gitignore
```

## Quick Reference for Common Scenarios

| Goal | Pattern |
|------|---------|
| Track single file | `!.path/to/file` |
| Track full directory | `!.path/to/dir/` + `!.path/to/dir/*` |
| Track nested dir only | Use parent `/*` + nested `!` patterns |
| Ignore file | Just add to .gitignore without `!` |
| Ignore directory contents | `dir/*` (keeps dir, ignores contents) |
| Ignore directory entirely | `dir/` |
