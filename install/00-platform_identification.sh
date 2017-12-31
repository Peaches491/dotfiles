#! /usr/bin/env bash

# http://stackoverflow.com/questions/3466166/how-to-check-if-running-in-cygwin-mac-or-linux
function detect_system() {
  # Default all to false
  export DOTFILES_is_mac=false
  export DOTFILES_is_linux=false
  export DOTFILES_is_windows=false
  if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform
    export DOTFILES_is_mac=true
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Do something under GNU/Linux platform
    export DOTFILES_is_linux=true
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    # Do something under Windows NT platform
    export DOTFILES_is_windows=true
  fi
}

function main() {
  detect_system
}

main
