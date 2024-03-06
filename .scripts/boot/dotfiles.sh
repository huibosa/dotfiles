#!/usr/bin/env bash

git clone --bare https://github.com/huibosa/dotfiles.git $HOME/.dotfiles

config() {
    usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}

config checkout
if [ $? = 0 ]; then
    echo "Checked out config."
else
    echo "Backing up pre-existing dot files."
    mkdir -p .dotfiles-backup
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
fi
config checkout

config config --local status.showUntrackedFiles no
