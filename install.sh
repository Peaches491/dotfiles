#!/usr/bin/env bash

set -euo pipefail
set -x

script_dir="$( (builtin cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) )"
root_dir="$( (builtin cd "$script_dir" && git rev-parse --show-toplevel) )"
home="$HOME"

################################################################################
# Command line args
################################################################################

full_install=false
if [[ $# -gt 0 && $1 = --full-install ]]; then
  full_install=true
fi

headless=false
if [[ $# -gt 1 && $2 = "--headless" ]]; then
  headless=true
fi


################################################################################
# Update repository
################################################################################

if [ "$full_install" ]; then
  # Tmux v2.0
  sudo add-apt-repository -y ppa:pi-rho/dev
  sudo apt-get update

  # Graphical programs
  if [ "$headless" ]; then
    sudo apt-get install -y \
      compiz-plugins \
      compizconfig-settings-manager \
      software-properties-common \
      terminator \

  fi

  # Command-line utilities
  sudo apt-get install -y \
    aptitude \
    build-essential \
    cmake \
    exuberant-ctags \
    htop \
    inotify-tools \
    python-dev \
    python-software-properties \
    tmux \
    vim \
    xclip \

else
  echo "--full-install not specified. linking only."
fi


################################################################################
# Update repository
################################################################################

if [ "$full_install" ]; then
  git submodule update --init --recursive
fi


################################################################################
# Set current directory
################################################################################

cd $root_dir


################################################################################
# Create required directories
################################################################################

mkdir -p $home/GitHub $home/include $home/.config $home/.bundles


################################################################################
# Link config files in home folder
################################################################################

function mklnk() {
   local source_file="$1"
   local mklnk_file="$2"

   $root_dir/link.py "$source_file" "$mklnk_file"
}

export -f mklnk

# Shell
mklnk $root_dir/shell/bashrc.sh $home/.bashrc
mklnk $root_dir/shell/zshrc.zsh $home/.zshrc
mklnk $root_dir/tmux.conf $home/.tmux.conf
mklnk $root_dir/.ros_config $home/.ros_config
mklnk $root_dir/themes $home/.themes
mklnk $root_dir/shell/commonrc.sh $home/.commonrc
mklnk $root_dir/shell/xinitrc.sh $home/.xinitrc
mklnk $root_dir/shell/alias.sh $home/.alias
mklnk $root_dir/shell/dircolors $home/.dircolors
mklnk $root_dir/shell/function.sh $home/.function
mklnk $root_dir/shell/colors.sh $home/.colors
mklnk $root_dir/shell/ssh_config $home/.ssh/config
#mklnk $root_dir/shell/variables.sh $home/.variables
#mklnk $root_dir/dircolors/solarized/dircolors.256dark $home/.dircolors

# Git
mklnk $root_dir/git/git-completion.sh $home/.git-completion.sh
mklnk $root_dir/git/gitconfig $home/.gitconfig
mklnk $root_dir/git/gitignore $home/.gitignore

# Vim
mklnk $root_dir/vim $home/.vim
mklnk $root_dir/vim $home/.ideavim
mklnk $root_dir/vim/vimrc $home/.vimrc
mklnk $root_dir/vim/ycm_extra_conf.py $home/.ycm_extra_conf.py

# TMux
mklnk $root_dir/tmux $home/.tmux

# Configs
for D in $root_dir/config/config/*; do
  echo $D | sed 's/.*\(config\/.*\)/~\/\.\1/g' | xargs $root_dir/link.py $D
done


mklnk $root_dir/config/Xmodmap $home/.Xmodmap
mklnk $root_dir/config/i3 $home/.i3


if [ ! "$full_install" ]; then
  exit 0
fi

echo "Installing TMux plugins..."
$home/.tmux/plugins/tpm/bin/install_plugins

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
  cd $home/.bundles/YouCompleteMe
  ./install.py --clang-completer
  #--system-libclang --system-boost
)
fi

# Powerline Fontconfig
if [ ! "$headless" ]; then
(
  mkdir -p $home/.fonts/
  $root_dir/themes/powerline-fonts/install.sh
  sudo fc-cache -vf $home/.fonts/
)
fi

source $home/.bashrc

