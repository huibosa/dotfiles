# Default APPS
export EDITOR="nvim"
# export READER="zathura"
# export BROWSER="chromium"
export PAPER="less"
export BACKUP="/backup"

# Path
export -U PATH
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.scripts:$PATH"
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.go/bin:$PATH"
export PATH="/usr/local/go/bin:$PATH"

export GOPROXY=https://goproxy.cn,direct
export GO111MODULE=on
export GOPATH="$HOME/.go"

export ERL_AFLAGS="-kernel shell_history enabled"
 
# Locale
export LC_ALL=en_US.UTF-8

# Set runtime library path
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"

# ZSH
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000000
export SAVEHIST=$HISTSIZE
setopt APPEND_HISTORY
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

# brew mirror
export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
export HOMEBREW_PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"

# Give color to manpage
export LESS_TERMCAP_mb=$'\E[1m\E[32m'
export LESS_TERMCAP_mh=$'\E[2m'
export LESS_TERMCAP_mr=$'\E[7m'
export LESS_TERMCAP_md=$'\E[1m\E[36m'
export LESS_TERMCAP_ZW=""
export LESS_TERMCAP_us=$'\E[4m\E[1m\E[37m'
export LESS_TERMCAP_me=$'\E(B\E[m'
export LESS_TERMCAP_ue=$'\E[24m\E(B\E[m'
export LESS_TERMCAP_ZO=""
export LESS_TERMCAP_ZN=""
export LESS_TERMCAP_se=$'\E[27m\E(B\E[m'
export LESS_TERMCAP_ZV=""
export LESS_TERMCAP_so=$'\E[1m\E[33m\E[44m'

# PROMPT_SUCCESS_COLOR='%{$fg_bold[white]%}'
# PROMPT_FAILURE_COLOR='%{$fg_bold[red]%}'
# PROMPT='%{$fg_bold[cyan]%}%c%{$reset_color%}%{$fg[green]%}'
# PROMPT+="%{%(?.$PROMPT_SUCCESS_COLOR.$PROMPT_FAILURE_COLOR)%}> "
# PROMPT+='%{$reset_color%}'

export LS_COLORS='di=34;01:*Makefile=38;5;178:*.ipynb=38;5;208:*.7z=31:*.WARC=31:*.a=31:*.arj=31:*.bz2=31:*.cpio=31:*.gz=31:*.lrz=31:*.lz=31:*.lzma=31:*.lzo=31:*.rar=31:*.s7z=31:*.sz=31:*.tar=31:*.tbz=31:*.tgz=31:*.warc=31:*.xz=31:*.z=31:*.zip=31:*.zipx=31:*.zoo=31:*.zpaq=31:*.zst=31:*.zstd=31:*.zz=31:*.gz=31:'

export UV_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
export UV_PYTHON_INSTALL_MIRROR="https://pypi.tuna.tsinghua.edu.cn/simple"

# zsh-autosuggestions settings
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_USE_ASYNC=1
