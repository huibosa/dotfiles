# zmodload zsh/zprof

# Forbid <c-s> to freeze terminal
unsetopt flow_control

# Append history immediatly
setopt incappendhistory
setopt sharehistory

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
fpath+="$HOME/.scripts/zsh/completions/"
zstyle ':completion:*' menu select=1 # menu block selection
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
autoload -U compinit && compinit -u

# Enter directory without type "cd"
setopt autocd


# Scripts
source $HOME/.scripts/boot/proxy.sh
source $HOME/.scripts/boot/utils.sh

# WSL setting
# if command -v "wsl.exe" &> /dev/null ; then
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
  source $HOME/.scripts/boot/utils-wsl.sh
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
alias vir="nvim -R"
alias gdb="gdb -q"

alias mv="mv -iv"
alias cp="cp -iv"
alias rm="rm -v"

alias python='python3'
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lazydot='lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# My prompt
#
# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

# Format the vcs_info_msg_0_ variable
# zstyle ':vcs_info:git:*' formats '(on %b)'
# RPROMPT=%{$fg_bold[yellow]%}\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats ' (%b)'
VCS_PROMPT=%{$fg_bold[yellow]%}\$vcs_info_msg_0_%{$reset_color%}

PROMPT_SUCCESS_COLOR='%{$fg_bold[white]%}'
PROMPT_FAILURE_COLOR='%{$fg_bold[red]%}'

PROMPT='%{$fg_bold[blue]%}%~'
PROMPT+='%(1j. %{$fg_bold[yellow]%}[%j]%{$reset_color%}.)'
PROMPT+="%{%(?.$PROMPT_SUCCESS_COLOR.$PROMPT_FAILURE_COLOR)%}> "
PROMPT+='%{$reset_color%}'

# Use antigen
source $HOME/.scripts/boot/antigen.zsh
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply

source <(zoxide init zsh)
source <(fzf --zsh)
source <(direnv hook zsh)

# zprof
