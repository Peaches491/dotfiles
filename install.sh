#!/usr/bin/env bash

ROOT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

wget -O ~/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

ln -s -b $ROOT_DIR/.bashrc ~/.bashrc
ln -s -b $ROOT_DIR/git/gitconfig ~/.gitconfig
ln -s -b $ROOT_DIR/.dircolors ~/.dircolors
ln -s -b $ROOT_DIR/.ros_config ~/.ros_config
ln -s -b $ROOT_DIR/.emacs ~/.emacs

source ~/.bashrc
