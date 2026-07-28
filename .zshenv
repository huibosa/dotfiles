# Default APPS
export EDITOR="nvim"
# export READER="zathura"
# export BROWSER="chromium"
export PAGER="less"
export BACKUP="/backup"

# Path
typeset -U path PATH
[[ -d /opt/homebrew/bin ]] && export PATH="/opt/homebrew/bin:$PATH" # macOS only
export PATH="$HOME/.scripts:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.go/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="/usr/local/go/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

export GOPROXY=https://goproxy.cn,direct
export GO111MODULE=on
export GOPATH="$HOME/.go"

export ERL_AFLAGS="-kernel shell_history enabled"
 
# Locale
export LC_ALL=en_US.UTF-8

# Set runtime library path
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$HOME/.local/lib"

# ZSH history file (options live in .zshrc — interactive shells only)
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000000
export SAVEHIST=$HISTSIZE

# Skip the duplicate compinit in /etc/zsh/zshrc — .zshrc runs its own
skip_global_compinit=1

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

export LS_COLORS='di=34;01:*Makefile=38;5;178:*.ipynb=38;5;208:*.7z=31:*.WARC=31:*.a=31:*.arj=31:*.bz2=31:*.cpio=31:*.gz=31:*.lrz=31:*.lz=31:*.lzma=31:*.lzo=31:*.rar=31:*.s7z=31:*.sz=31:*.tar=31:*.tbz=31:*.tgz=31:*.warc=31:*.xz=31:*.z=31:*.zip=31:*.zipx=31:*.zoo=31:*.zpaq=31:*.zst=31:*.zstd=31:*.zz=31:*.gz=31:'

export UV_INDEX_URL="https://mirrors.aliyun.com/pypi/simple"
# export UV_PYTHON_INSTALL_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/python-build-standalone/"

# zsh-autosuggestions settings
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_USE_ASYNC=1

# fzf configuration (faster with fd)
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --no-ignore-vcs \
  --exclude .git/ --exclude .venv/ --exclude venv/ \
  --exclude node_modules/ --exclude .cache/ \
  --exclude __pycache__/ --exclude .pytest_cache/ \
  --exclude .mypy_cache/ --exclude .tox/ --exclude .bun/ \
  --exclude dist/ --exclude build/ \
  --exclude .idea/ --exclude '*.egg-info/'"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --no-ignore-vcs \
  --exclude .git/ --exclude .venv/ --exclude venv/ \
  --exclude node_modules/ --exclude .cache/"

export FZF_DEFAULT_OPTS="--height 40% --layout reverse --border --info inline"

source $HOME/.claude/.envrc
