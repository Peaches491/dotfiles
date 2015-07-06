#!/usr/bin/env bash

set -e

function link() {
   local source_file="$1"
   local link_file="$2"

   rm -rf "$link_file"
   ln -si "$source_file" "$link_file"
}

(

sudo apt-get install build-essential cmake python-dev

################################################################################
# Update repository
################################################################################

echo "Clone all submodules? y/n "
read year
if (( "$year" == "y" )) || (( "$year" == "Y")); then
  git submodule update --init --recursive
fi

################################################################################
# Set current directory
################################################################################

ROOT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $ROOT_DIR

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
#link ~/dotfiles/dircolors/solarized/dircolors.256dark ~/.dircolors
link $ROOT_DIR/shell/.bashrc ~/.bashrc
link $ROOT_DIR/shell/zshrc.zsh ~/.zshrc
link $ROOT_DIR/tmux.conf ~/.tmux.conf

# Git
link $ROOT_DIR/git-completion.sh ~/.git-completion.sh
link $ROOT_DIR/git/gitconfig ~/.gitconfig
link $ROOT_DIR/git/gitignore ~/.gitignore
    
wget -O ~/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
   
# YouCompleteMe
(
  cd ./vim/bundle/YouCompleteMe
  ./install.sh --clang-completer --omnisharp-completer
)

ln -s -i $ROOT_DIR/.bashrc ~/.bashrc
ln -s -i $ROOT_DIR/git/gitconfig ~/.gitconfig
ln -s -i $ROOT_DIR/.dircolors ~/.dircolors
ln -s -i $ROOT_DIR/.ros_config ~/.ros_config
ln -s -i $ROOT_DIR/.emacs ~/.emacs
ln -s -i $ROOT_DIR/vim/vimrc ~/.vimrc
ln -s -i $ROOT_DIR/vim ~/.vim
ln -s -i $ROOT_DIR/vim/ycm_extra_conf.py ~/.ycm_extra_conf.py
 
)

source ~/.bashrc
