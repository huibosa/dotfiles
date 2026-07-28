# zmodload zsh/zprof

# Forbid <c-s> to freeze terminal
unsetopt flow_control

# History (interactive shells only)
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
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit          # full security check at most once per day
else
    compinit -C       # skip the check, use the cached dump
fi

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
alias omo='opencode'
alias oc='opencode --pure'

# My prompt
#
# Load version control information
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats '%b'

# Add dirty indicator
# zstyle ':vcs_info:git+set-message:*' hooks git-dirty

# function +vi-git-dirty() {
    #     local gitstatus=$(command git status --porcelain -uno 2>/dev/null)
    #     if [[ -n "$gitstatus" ]]; then
        #         hook_com[branch]+='*'
    #     fi
# }

precmd() {
    vcs_info
    if [[ -n $vcs_info_msg_0_ ]]; then
        vcs_info_msg_0_=":$vcs_info_msg_0_"
    fi
    # Build background job indicator (one ">" per job)
    BG_PROMPT=""
    local i
    for i in ${(k)jobstates}; do
        BG_PROMPT+=">"
    done
    # Split path: parent path (blue) + last dir (yellow if in git)
    LAST_DIR=${(%):-%1~}
    FULL_PATH=${(%):-%~}
    if [[ $FULL_PATH == $LAST_DIR ]]; then
        PARENT_PATH=""
    else
        PARENT_PATH="${FULL_PATH%/*}/"
    fi
    # Only color last dir yellow if in a git directory
    if [[ -n $vcs_info_msg_0_ ]]; then
        PATH_PROMPT="%{$fg_bold[blue]%}${PARENT_PATH}%{$fg_bold[yellow]%}${LAST_DIR}"
    else
        PATH_PROMPT="%{$fg_bold[blue]%}${PARENT_PATH}${LAST_DIR}"
    fi
}

# VCS prompt for git branches (no longer needed, using vcs_info_msg_0_ directly)
PROMPT_SUCCESS_COLOR='%{$fg_bold[white]%}'
PROMPT_FAILURE_COLOR='%{$fg_bold[red]%}'

PROMPT='${PATH_PROMPT}${vcs_info_msg_0_}%{$reset_color%}%{%(?.%{$fg_bold[white]%}.%{$fg_bold[red]%})%}${BG_PROMPT}>%{$reset_color%} '

# Tools that register ZLE widgets — load before syntax-highlighting so it wraps them
source <(zoxide init zsh)
source <(fzf --zsh)
source <(direnv hook zsh)

# Use antigen — zsh-syntax-highlighting must be applied last
source $HOME/.scripts/boot/antigen.zsh
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply

# zprof
