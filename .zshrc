# bindkey -e
# 
# # color for prompt
# autoload -U colors && colors
# 
# # always refresh prompt
# setopt prompt_subst
# 
# autoload -Uz compinit
# compinit -u
# alias compinit="echo no more compinit!"


#+use antigen
source $HOME/.scripts/antigen.zsh

antigen use oh-my-zsh

antigen bundle z
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting

antigen apply
#-use antigen


source $HOME/.config/lf/lfcd.sh
source $HOME/.scripts/proxy.sh


# case command for wsl
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
  alias open="explorer.exe"
fi


# aliases
alias vi="nvim"
alias py="python3"
alias mv="mv -iv"
alias cp="cp -iv"
alias rm="rm -v"
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lf="lfcd"
