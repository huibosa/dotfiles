# oh my zsh settings
plugins=(z zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh


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
