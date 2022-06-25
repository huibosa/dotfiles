# zmodload zsh/zprof

# Forbid <c-s> to freeze terminal
unsetopt flow_control


# Commandline editting
bindkey -e                       # Emacs keybindings
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line # <C-X><C-E> to edit command in $EDITOR


# No back-word-kill-word on directory delimiter
autoload -U select-word-style
select-word-style bash


# Prompt
autoload -U colors && colors
setopt prompt_subst


# Completion
zstyle ':completion:*' menu select=1 # menu block selection
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
autoload -U compinit && compinit -u


# Use antigen
source $HOME/.scripts/antigen.zsh
antigen bundle agkozak/zsh-z
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply


# Scripts
source $HOME/.scripts/proxy.sh    # proxy settings
source $HOME/.scripts/utils.sh
bindkey -s '^o' 'lfcd\n'          # bind lfcd to <c-o>


# WSL setting
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
  alias display="eog"
  alias open="explorer.exe"
  alias typora="Typora.exe"
  alias sumatra="SumatraPDF.exe"
  alias potplayer="PotPlayerMini64.exe"
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

alias mv="mv -iv"
alias cp="cp -iv"
alias rm="rm -v"

alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias screenkey="screenkey --scr 1 --opacity 0.5"

# zprof
