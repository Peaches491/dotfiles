#!/usr/bin/env bash

set -e

function mklnk() {
   local source_file="$1"
   local mklnk_file="$2"

   link.py "$source_file" "$mklnk_file"
}
export -f mklnk

(

################################################################################
# Update repository
################################################################################

if [ "$1" == "--full-install" ] 
then
  sudo apt-get install build-essential cmake python-dev
else
  echo "--full-install not specified. linking only."
fi


################################################################################
# Update repository
################################################################################

if [ "$1" == "--full-install" ] 
then
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

mkdir -p ~/GitHub ~/include ~/.config ~/.bundles


################################################################################
# Link config files in home folder
################################################################################

# Shell
mklnk $ROOT_DIR/shell/bashrc ~/.bashrc
mklnk $ROOT_DIR/shell/zshrc.zsh ~/.zshrc
mklnk $ROOT_DIR/tmux.conf ~/.tmux.conf
mklnk $ROOT_DIR/.ros_config ~/.ros_config
mklnk $ROOT_DIR/themes ~/.themes
mklnk $ROOT_DIR/shell/commonrc.sh ~/.commonrc
mklnk $ROOT_DIR/shell/xinitrc.sh ~/.xinitrc
mklnk $ROOT_DIR/shell/alias.sh ~/.alias
mklnk $ROOT_DIR/shell/dircolors ~/.dircolors
mklnk $ROOT_DIR/shell/function.sh ~/.function
mklnk $ROOT_DIR/shell/colors.sh ~/.colors
#mklnk $ROOT_DIR/shell/variables.sh ~/.variables
#mklnk $ROOT_DIR/dircolors/solarized/dircolors.256dark ~/.dircolors

# Git
mklnk $ROOT_DIR/git/git-completion.sh ~/.git-completion.sh
mklnk $ROOT_DIR/git/gitconfig ~/.gitconfig
mklnk $ROOT_DIR/git/gitignore ~/.gitignore

# Vim
mklnk $ROOT_DIR/vim ~/.vim
mklnk $ROOT_DIR/vim ~/.ideavim
mklnk $ROOT_DIR/vim/vimrc ~/.vimrc
mklnk $ROOT_DIR/vim/ycm_extra_conf.py ~/.ycm_extra_conf.py

# Configs
for D in ~/.dotfiles/config/*; do 
  echo $D | sed 's/.*\(config\/.*\)/\/home\/daniel\/\.\1/g' | xargs link.py $D  
done


if [ "$1" != "--full-install" ] 
then
  exit 0
fi



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

