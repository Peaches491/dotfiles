#!/usr/bin/env bash

set -e

(

################################################################################
# Update repository
################################################################################

if [ "$1" == "--full-install" ] 
then
  # Tmux v2.0
  sudo add-apt-repository -y ppa:pi-rho/dev
  sudo apt-get update

  sudo apt-get install -y \
    aptitude \
    build-essential \
    cmake \
    compiz-plugins \
    compizconfig-settings-manager \
    exuberant-ctags \
    htop \
    inotify-tools \
    libboost-all-dev \
    libclang-dev \
    python-dev \
    python-software-properties \
    software-properties-common \
    terminator \
    tree \
    tmux \
    vim \
    xclip \

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

function mklnk() {
   local source_file="$1"
   local mklnk_file="$2"

   $ROOT_DIR/link.py "$source_file" "$mklnk_file"
}
export -f mklnk

# Shell
mklnk $ROOT_DIR/shell/bashrc.sh ~/.bashrc
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
mklnk $ROOT_DIR/shell/ssh_config ~/.ssh/config
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

# TMux
mklnk $ROOT_DIR/tmux ~/.tmux

# Configs
for D in $ROOT_DIR/config/config/*; do 
  echo $D | sed 's/.*\(config\/.*\)/~\/\.\1/g' | xargs $ROOT_DIR/link.py $D
done

mklnk $ROOT_DIR/config/Xmodmap ~/.Xmodmap
mklnk $ROOT_DIR/config/i3 ~/.i3


if [ "$1" != "--full-install" ] 
then
  exit 0
fi

echo "Installing TMux plugins..."
~/.tmux/plugins/tpm/bin/install_plugins

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
  ./install.py --clang-completer
  #--system-libclang --system-boost
)
fi

# Powerline Fontconfig
(
mkdir -p ~/.fonts/
$ROOT_DIR/themes/powerline-fonts/install.sh
sudo fc-cache -vf ~/.fonts/
)

)

source ~/.bashrc

