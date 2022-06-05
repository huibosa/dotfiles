# ENV just for wsl
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
  export WINHOME="/mnt/c/Users/huibo"
fi

# Default APPS
export EDITOR="nvim"
export READER="zathura"
export BROWSER="chromium"
export PAPER="less"
export BACKUP="/backup"

# Path
export -U PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.scripts:$PATH"
export PATH="$HOME/.go/bin:$PATH"
export PATH="/usr/local/go/bin:$PATH"

# Golang
export GOPROXY="https://goproxy.io"
export GOPATH="$HOME/.go"
 
# Locale
export LC_ALL=en_US.UTF-8

# ZSH
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000000
# export HISTCONTROL=ignorespace
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY

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

# My prompt
PROMPT_SUCCESS_COLOR='%{$fg_bold[green]%}'
PROMPT_FAILURE_COLOR='%{$fg_bold[red]%}'
PROMPT='%{$fg_bold[cyan]%}%c%{$reset_color%}%{$fg[green]%}'
PROMPT+="%{%(?.$PROMPT_SUCCESS_COLOR.$PROMPT_FAILURE_COLOR)%} > "
PROMPT+='%{$reset_color%}'

LS_COLORS='di=34;01:*Makefile=33:*.7z=31:*.WARC=31:*.a=31:*.arj=31:*.bz2=31:*.cpio=31:*.gz=31:*.lrz=31:*.lz=31:*.lzma=31:*.lzo=31:*.rar=31:*.s7z=31:*.sz=31:*.tar=31:*.tbz=31:*.tgz=31:*.warc=31:*.xz=31:*.z=31:*.zip=31:*.zipx=31:*.zoo=31:*.zpaq=31:*.zst=31:*.zstd=31:*.zz=31:'

export LS_COLORS
