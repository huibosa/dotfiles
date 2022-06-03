# zmodload zsh/zprof

# Ban ctrl-s which freese terminal
unsetopt flow_control


# Commandline editting
bindkey -e  # Emacs keybindings
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line # <C-X><C-E> to edit in $EDITOR


# No back-word-kill-word on directory delimiter
autoload -U select-word-style
select-word-style bash


# Prompt
autoload -U colors && colors
setopt prompt_subst


# Completion
autoload -Uz compinit && compinit -u
zstyle ':completion:*' menu select # menu block selection


# Use antigen
source $HOME/.scripts/antigen.zsh
antigen bundle agkozak/zsh-z
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply


# Scripts
source $HOME/.scripts/proxy.sh    # proxy settings
source $HOME/.scripts/lfcd.sh     # for auto change directory


# WSL setting
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
  alias display="eog"
  alias open="explorer.exe"
fi


# Aliases
alias ..="cd .."
alias -- -='cd -'
alias ~="cd ~"
alias /="cd /"

alias ls="ls --color=auto"
alias la="ls -lAh --color=auto"
alias l="ls -lah --color=auto"
alias ll="ls -lh --color=auto"

alias vi="nvim"
alias lf="lfcd"

alias mv="mv -iv"
alias cp="cp -iv"
alias rm="rm -v"

alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias screenkey="screenkey --scr 1 --opacity 0.5"

# zprof
