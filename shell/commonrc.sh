#! /usr/bin/env sh

###############################################################################
# Login Actions.
###############################################################################

# If not running interactively, don't do anything.
case $- in
   *i*) ;;
   *) return;;
esac


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

function readlink_f() {
  TARGET_FILE=$1

  cd `dirname $TARGET_FILE`
  TARGET_FILE=`basename $TARGET_FILE`

  # Iterate down a (possible) chain of symlinks
  while [ -L "$TARGET_FILE" ]
  do
      TARGET_FILE=`readlink $TARGET_FILE`
      cd `dirname $TARGET_FILE`
      TARGET_FILE=`basename $TARGET_FILE`
  done

  # Compute the canonicalized name by finding the physical path
  # for the directory we're in and appending the target file.
  PHYS_DIR=`pwd -P`
  RESULT=$PHYS_DIR/$TARGET_FILE
  echo $RESULT
}


###############################################################################
# Environment Variables
###############################################################################
script_abspath="$(readlink_f ${BASH_SOURCE[0]})"
script_dir="$( (builtin cd "$(dirname "$script_abspath")" && pwd) )"
root_dir="$( (builtin cd "$script_dir" && git rev-parse --show-toplevel) )"
export DOTFILES_ROOT="$root_dir"
detect_system


###############################################################################
# External Files.
###############################################################################

[ -f ~/.bash_completion ] && . ~/.bash_completion
[ -f ~/.alias ] && . ~/.alias
[ -f ~/.colors ] && . ~/.colors
[ -f ~/.function ] && . ~/.function
[ -f ~/.variables ] && . ~/.variables

# Load functions listed in hooks.d
run_scripts ~/dotfiles/shell/hooks.d

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi
if [ -f ~/.dircolors ]; then
    eval $(dircolors ~/.dircolors)
fi

if [ "$DISPLAY" ]; then
   if [ `echo $DESKTOP_SESSION | grep "gnome|ubuntu"` ] &&
    [ -d ~/.themes/solarized/gnome-terminal-colors-solarized ]; then
      ~/.themes/gnome-terminal-colors-solarized/set_dark.sh
   elif [ `echo $DESKTOP_SESSION | grep -E "konsole|kde"` ] &&
    [ -d ~/.themes/solarized/konsole-colors-solarized ]; then
      ~/.themes/konsole-colors-solarized/set_dark.sh
   fi
fi


###############################################################################
# History Settings.
###############################################################################

export HISTFILE=~/.history
export SAVEHIST=1000
export HISTSIZE=1000
export HISTFILESIZE=2000


###############################################################################
# Path Construction.
###############################################################################

# personal bin directories
OLD_PATH=$PATH
PATH='.'
[ -d ~/bin ] && PATH+=:~/bin
[ -d ~/sbin ] && PATH+=:~/sbin
[ -d ~/.scripts ] && PATH+=:~/.scripts
# Rust binaries
[ -d ~/.cargo/bin ] && PATH+=:~/.cargo/bin
# homebrew bin directories
[ -d /usr/local/bin ] && PATH+=:/usr/local/bin
[ -d /usr/local/sbin ] && PATH+=:/usr/local/sbin
# usr bin directories
[ -d /usr/bin ] && PATH+=:/usr/bin
[ -d /usr/sbin ] && PATH+=:/usr/sbin
# mysql bin directories
[ -d /usr/local/mysql/bin ] && PATH+=:/usr/local/mysql/bin
[ -d /usr/local/mysql/sbin ] && PATH+=:/usr/local/mysql/sbin
# X11 bin directory
[ -d /usr/X11/bin ] && PATH+=:/usr/X11/bin
# CUDA bin directories
[ -d /usr/local/cuda/bin ] && PATH+=:/usr/local/cuda/bin
[ -d /usr/local/cuda-5.0/bin ] && PATH+=:/usr/local/cuda-5.0/bin
# kerberos bin directories
[ -d /usr/kerberos/bin ] && PATH+=:/usr/kerberos/bin
[ -d /usr/kerberos/sbin ] && PATH+=:/usr/kerberos/sbin
# system bin directories
[ -d /bin ] && PATH+=:/bin
[ -d /sbin ] && PATH+=:/sbin
# CCache compiler locations
#[ -d /usr/lib/ccache ] && PATH+=:/usr/lib/ccache
# Submodules of this Dotfiles repo
[ -d $DOTFILES_ROOT/modules/ssh-agent-canonicalize ] && \
    PATH+=:$DOTFILES_ROOT/modules/ssh-agent-canonicalize
export PATH="$OLD_PATH:$PATH"


###############################################################################
# LD Library Path Construction.
###############################################################################

LD_LIBRARY_PATH=./lib
[ -d /lib ] && LD_LIBRARY_PATH+=:/lib
[ -d /usr/lib ] && LD_LIBRARY_PATH+=:/usr/lib
[ -d /usr/local/lib ] && LD_LIBRARY_PATH+=:/usr/local/lib
[ -d /usr/local/cuda/lib ] && LD_LIBRARY_PATH+=:/usr/local/cuda/lib
[ -d /usr/local/cuda/lib64 ] && LD_LIBRARY_PATH+=:/usr/local/cuda/lib64
[ -d /usr/local/cuda-5.0/lib ] && LD_LIBRARY_PATH+=:/usr/local/cuda-5.0/lib
[ -d /usr/local/cuda-5.0/lib64 ] && LD_LIBRARY_PATH+=:/usr/local/cuda-5.0/lib64
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH


###############################################################################
# Prompt Definition
###############################################################################

# Defined externally:
# ps1_fg_black, ps1_fg_red, ps1_fg_green, ps1_fg_yellow, ps1_fg_blue,
# ps1_fg_magenta, ps1_fg_cyan, ps1_fg_white, ps1_reset_color,
# SH_name, SH_host, SH_pwd, SH_date, SH_time, SH_priv

PS1_lbrace="${ps1_fg_blue}[${ps1_reset_color}"
PS1_rbrace="${ps1_fg_blue}]${ps1_reset_color}"
PS1_vbar="${ps1_fg_green}|${ps1_reset_color}"
PS1_at="${ps1_fg_white}@${ps1_reset_color}"
PS1_rangle="${ps1_fg_white}>${ps1_reset_color}"
PS1_name="${ps1_fg_yellow}${SH_name}${ps1_reset_color}"
PS1_host="${ps1_fg_white}${SH_host}${ps1_reset_color}"
PS1_time="${ps1_fg_orange}${SH_time}${ps1_reset_color}"
PS1_date="${ps1_fg_magenta}${SH_date}${ps1_reset_color}"
PS1_pwd="${ps1_fg_blue}${SH_pwd}${ps1_reset_color}"
PS1_priv="${ps1_fg_white}${SH_priv}${ps1_reset_color}"

declare PROMPT_COMMAND="prompt_command"

export PS1="$SH_name$SH_at$SH_host $SH_lbrace$SH_pwd$SH_rbrace $SH_time
 $SH_priv "

prompt_command
PROMPT=$PS1


###############################################################################
# Language
###############################################################################
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_COLLATE=C
export LC_MONETARY="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_PAPER="en_US.UTF-8"
export LC_NAME="en_US.UTF-8"
export LC_ADDRESS="en_US.UTF-8"
export LC_TELEPHONE="en_US.UTF-8"
export LC_MEASUREMENT="en_US.UTF-8"
export LC_IDENTIFICATION="en_US.UTF-8"
export LC_ALL=
export CHARSET=UTF-8


###############################################################################
# Computer Language
###############################################################################
export PYTHONDONTWRITEBYTECODE=1


###############################################################################
# Source command line utils
###############################################################################

# Workspaces
if [ -f $DOTFILES_ROOT/shell/tools/workspaces.sh ]; then
   . $DOTFILES_ROOT/shell/tools/workspaces.sh
fi

# ROS
[ -f ~/.ros_config ] && . ~/.ros_config

# Bazel completion
bazel_complete='/usr/local/lib/bazel/bin/bazel-complete.bash'
[ -f $bazel_complete ] && . $bazel_complete

export NVM_DIR="/home/daniel/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm


###############################################################################
# Run TMux!
###############################################################################

export TERM=xterm-256color

if [ ! $TMUX ]; then
   tmux #new-session -A -s main
fi

if [[ `(cd $DOTFILES_ROOT; git status --porcelain)` ]]; then
    echo 'SHAME: You have unstaged changes in your Dotfiles repo!'
fi

