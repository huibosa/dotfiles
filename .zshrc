# oh my zsh settings
plugins=(z zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
bindkey ',' autosuggest-accept


# my prompt
source $HOME/.scripts/git-prompt.sh
PROMPT='%{$fg_bold[cyan]%}%c%{$reset_color%}$(git_prompt_info)%{$fg[green]%}'
PROMPT+="%(?:%{$fg_bold[green]%}:%{$fg_bold[red]%}) > %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg_bold[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"


# lfcd
source $HOME/.config/lf/lfcd.sh


# case command for wsl
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
  alias open="explorer.exe"
  source "$HOME/.scripts/wsl-proxy.sh"
fi


# aliases
alias vi="nvim"
alias py="python3"
alias mv="mv -iv"
alias cp="cp -iv"
alias rm="rm -v"
alias px="proxychains"
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lf="lfcd"

