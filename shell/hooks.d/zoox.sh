# Add ccache to PATH
export PATH=/usr/lib/ccache:$PATH
export VLR_ROOT=/home/daniel/

export ZOOX_CMAKE_OPTIONS=""

# Override roscompile for threading
function zoox-build(){
(
  cd $ROS_WORKSPACE
  pwd


  if [ -n "$TMUX" ]; then
    printf '\033kzoox-build ~\033\\'
  fi

  success=$?

  if [[ "core" == "$1" ]]; then
    catkin_make $ZOOX_CMAKE_OPTIONS
    success=$?
  elif [[ "all" == "$1" ]]; then
    catkin_make all tests $ZOOX_CMAKE_OPTIONS
    success=$?
  else
    catkin_make $1 $ZOOX_CMAKE_OPTIONS
    success=$?
  fi

  if [ $success -eq 0 ]; then
    notify-send "zoox-build" "Build Succeeded" --icon=/home/daniel/dotfiles/resources/icons/tick_128.png
    if [ -n "$TMUX" ]; then
      printf '\033kzoox-build \342\234\223\033\\'
    fi
  else
    notify-send "zoox-build" "Build Failed" --icon=/home/daniel/dotfiles/resources/icons/cross_128.png
    if [ -n "$TMUX" ]; then
      printf '\033kzoox-build \342\234\227\033\\'
    fi
  fi

  return $success
)
}

_zoox-build()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="all core tests download_test_data"

        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
}
complete -F _zoox-build zoox-build

