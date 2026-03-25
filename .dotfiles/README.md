# Dotfiles Repository

This repository manages configuration files using a **bare Git repository** pattern.
Instead of symlinking or using complex tools, we use a bare repo with a `dot` alias.

## Quick Start (Install on New System)

To set up these dotfiles on a fresh machine:

### 1. Define the `dot` alias

Add this alias to your shell configuration (`.bashrc`, `.zshrc`, etc.):

```bash
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

Then reload your shell:
```bash
source ~/.bashrc  # or ~/.zshrc
```

### 2. Clone the bare repository

```bash
git clone --bare <your-repo-url> $HOME/.dotfiles
```

### 3. Checkout the files

```bash
dot checkout
```

### 4. Handle conflicts (if any)

If you see errors like "would be overwritten by checkout", back up existing files:

```bash
mkdir -p .config-backup
dot checkout 2>&1 | grep "^\s*\." | awk '{print $1}' | xargs -I{} mv {} .config-backup/{}
dot checkout
```

### 5. Hide untracked files

Prevent `dot status` from showing all files in your home directory:

```bash
dot config --local status.showUntrackedFiles no
```

---

## Dependencies

These dotfiles configure various command-line tools. You don't need to install everything—only what you actually use.

### Core Requirements

| Tool | Purpose | Installation |
|------|---------|--------------|
| `git` | Version control | [git-scm.com](https://git-scm.com/downloads) |
| `zsh` | Shell (required for these dotfiles) | [zsh.sourceforge.io](https://zsh.sourceforge.io) |

### Optional Enhancements

The following tools are referenced in these dotfiles. Install only the ones you want:

#### Shell Enhancements
- `zoxide` - Smart directory jumping ([github.com/ajeetdsouza/zoxide](https://github.com/ajeetdsouza/zoxide))
- `fzf` - Fuzzy finder ([github.com/junegunn/fzf](https://github.com/junegunn/fzf))
- `direnv` - Directory-specific environment variables ([direnv.net](https://direnv.net))

#### Development Tools
- `nvim` or `vim` - Text editor ([neovim.io](https://neovim.io))
- `lazygit` - Terminal UI for git ([github.com/jesseduffield/lazygit](https://github.com/jesseduffield/lazygit))
- `tmux` - Terminal multiplexer ([github.com/tmux/tmux](https://github.com/tmux/tmux))

#### File Management
- `yazi` - Terminal file manager ([github.com/sxyazi/yazi](https://github.com/sxyazi/yazi))
- `lf` - Another terminal file manager ([github.com/gokcehan/lf](https://github.com/gokcehan/lf))

#### System Monitoring
- `btop` - System resource monitor ([github.com/aristocratos/btop](https://github.com/aristocratos/btop))
- `htop` - Interactive process viewer ([htop.dev](https://htop.dev))

### Installing Dependencies

Since everyone uses different platforms and package managers, here are general guidelines:

**Find your package manager:**
- **macOS**: Homebrew (`brew install <package>`)
- **Ubuntu/Debian**: APT (`apt install <package>`)
- **Arch Linux**: Pacman (`pacman -S <package>`)
- **Fedora**: DNF (`dnf install <package>`)
- **Windows (WSL)**: Use the Linux distribution's package manager
- **Other**: Check the tool's official documentation

**Example workflow:**
```bash
# 1. Check if a tool is installed
which zoxide

# 2. If not found, install it using your package manager
# (see tool's GitHub page for specific instructions)

# 3. Verify installation
zoxide --version
```

### WSL-Specific Notes

If using Windows Subsystem for Linux, these dotfiles include aliases for Windows applications:
- VS Code
- PowerShell
- WezTerm

These aliases assume standard installation paths. Adjust `.scripts/boot/utils-wsl.sh` if your paths differ.

---

## Daily Usage

Once set up, use the `dot` command just like `git`:

| Command | Description |
|---------|-------------|
| `dot status` | Check which files are modified |
| `dot add .vimrc` | Stage a file for commit |
| `dot commit -m "Update vim config"` | Commit changes |
| `dot push` | Push to remote |
| `dot pull` | Pull latest changes |
| `dot diff` | See what changed |
| `dot log --oneline` | View commit history |

### Adding a new dotfile

```bash
# From your home directory
dot add .config/new-tool/config.toml
dot commit -m "Add new-tool config"
dot push
```

### Syncing changes

```bash
dot pull          # Fetch and merge
dot push          # Push your changes
```

---

## How It Works

- **Bare repository**: Stored in `~/.dotfiles/` (no working directory)
- **Work tree**: Your actual home directory `~/`
- **The `dot` alias**: Tells git to use `~/.dotfiles` as the repo, but `~` as the working tree

This lets you track files from anywhere in your home directory without symlinks.

---

## Making the Alias Permanent

Add the alias to your shell's config file so it's available in new terminals:

### Bash
```bash
echo "alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> ~/.bashrc
```

### Zsh
```bash
echo "alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> ~/.zshrc
```

### Fish
```bash
echo "alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> ~/.config/fish/config.fish
```

---

## Excluding Private Files

Private files (API keys, personal tokens) should not be committed. Add patterns to `~/.gitignore`:

```bash
# Don't track these
.ssh/id_rsa
.env
*.key
.personal
```

Then commit the `.gitignore`:
```bash
dot add .gitignore
dot commit -m "Add gitignore for private files"
dot push
```

---

## Troubleshooting

### `dot` command not found
Make sure the alias is defined and your shell is reloaded.

### "would be overwritten by checkout"
Run the backup commands from step 4 in the Quick Start.

### Seeing thousands of untracked files
Run: `dot config --local status.showUntrackedFiles no`

### Permission denied when running `dot`
Make sure the git binary path is correct:
- Check with: `which git`
- Update alias if needed: `alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'`

---

## Resources

- [Atlassian Git Tutorial: The Best Way to Store Your Dotfiles](https://www.atlassian.com/git/tutorials/dotfiles)
- `man git` - Standard git commands work with `dot`
