# ENV just for wsl
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
  export WINHOME="/mnt/c/Users/huibo"
fi

# Default APPS
export EDITOR="nvim"
export READER="zathura"
export BROWSER="chromium"
export PAPER="less"
export WM="dwm"

# Path
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.scripts:$PATH"

# Golang
export Go111MODULE="on"
export GOPROXY="https://goproxy.io"
 
# Lang
export LC_ALL=en_US.UTF-8

# ZSH
export ZSH="$HOME/.oh-my-zsh"
 
# give color to manpage
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


