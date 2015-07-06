#!/usr/bin/env bash

set -e

function link() {
   local source_file="$1"
   local link_file="$2"

   rm -rf "$link_file"
   ln -sf "$source_file" "$link_file"
}

(

sudo apt-get install build-essential cmake python-dev

################################################################################
# Set current directory
################################################################################

ROOT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $ROOT_DIR

################################################################################
# Update repository
################################################################################

git submodule update --init --recursive

################################################################################
# Create required directories
################################################################################

mkdir -p ~/GitHub ~/include ~/.config

################################################################################
# Link config files in home folder
################################################################################

# Shell
#link ~/dotfiles/sh/alias.sh ~/.alias
#link ~/dotfiles/sh/function.sh ~/.function
#link ~/dotfiles/sh/variables.sh ~/.variables
#link ~/dotfiles/sh/commonrc.sh ~/.commonrc
#link ~/dotfiles/sh/bashrc.bash ~/.bashrc
#link ~/dotfiles/sh/zshrc.zsh ~/.zshrc
#link ~/dotfiles/dircolors/solarized/dircolors.256dark ~/.dircolors
link $ROOT_DIR/tmux.conf ~/.tmux.conf

# Git
link ~/dotfiles/sh/git-completion.sh ~/.git-completion.sh
link ~/dotfiles/git/gitconfig ~/.gitconfig
link ~/dotfiles/git/gitignore ~/.gitignore
    
wget -O ~/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
   
# YouCompleteMe
(
  cd ./vim/bundle/YouCompleteMe
  ./install.sh --clang-completer --omnisharp-completer
)

ln -s -b $ROOT_DIR/.bashrc ~/.bashrc
ln -s -b $ROOT_DIR/git/gitconfig ~/.gitconfig
ln -s -b $ROOT_DIR/.dircolors ~/.dircolors
ln -s -b $ROOT_DIR/.ros_config ~/.ros_config
ln -s -b $ROOT_DIR/.emacs ~/.emacs
ln -s -b $ROOT_DIR/vim/vimrc ~/.vimrc
ln -s -b $ROOT_DIR/vim ~/.vim
ln -s -b $ROOT_DIR/vim/ycm_extra_conf.py ~/.ycm_extra_conf.py
 
)

source ~/.bashrc
