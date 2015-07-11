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
# Update repository
################################################################################

git submodule update --init --recursive

################################################################################
# Set current directory
################################################################################

ROOT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $ROOT_DIR

################################################################################
# Create required directories
################################################################################

mkdir -p ~/GitHub ~/include ~/.config ~/.bundles

################################################################################
# Link config files in home folder
################################################################################

# Shell
link $ROOT_DIR/shell/bashrc ~/.bashrc
link $ROOT_DIR/shell/zshrc.zsh ~/.zshrc
link $ROOT_DIR/tmux.conf ~/.tmux.conf
link $ROOT_DIR/.dircolors ~/.dircolors
link $ROOT_DIR/.ros_config ~/.ros_config
link $ROOT_DIR/themes ~/.themes
link $ROOT_DIR/shell/commonrc.sh ~/.commonrc
link $ROOT_DIR/shell/xinitrc.sh ~/.xinitrc
link $ROOT_DIR/shell/alias.sh ~/.alias
#link $ROOT_DIR/shell/function.sh ~/.function
#link $ROOT_DIR/shell/variables.sh ~/.variables
#link $ROOT_DIR/dircolors/solarized/dircolors.256dark ~/.dircolors

# Git
link $ROOT_DIR/git/git-completion.sh ~/.git-completion.sh
link $ROOT_DIR/git/gitconfig ~/.gitconfig
link $ROOT_DIR/git/gitignore ~/.gitignore

# Vim
link $ROOT_DIR/vim ~/.vim
link $ROOT_DIR/vim ~/.ideavim
link $ROOT_DIR/vim/vimrc ~/.vimrc
link $ROOT_DIR/vim/ycm_extra_conf.py ~/.ycm_extra_conf.py

# Emacs
link $ROOT_DIR/.emacs ~/.emacs
 

# YouCompleteMe
echo "Reinstall Vundle Bundles? y/n "
read bundleinstall
if [ "$bundleinstall" == "y" ] || [ "$bundleinstall" == "Y" ]; then
(
  vim +BundleInstall +qall
)
fi

# YouCompleteMe
echo "Recompile YouCompleteMe? y/n "
read recomp
if [ "$recomp" == "y" ] || [ "$recomp" == "Y" ]; then
(
  cd ~/.bundles/YouCompleteMe
  ./install.sh --clang-completer --omnisharp-completer
)
fi

# Powerline Fontconfig
(
mkdir -p ~/.fonts/
. themes/powerline-fonts/install.sh
sudo fc-cache -vf ~/.fonts/
)

)

source ~/.bashrc

