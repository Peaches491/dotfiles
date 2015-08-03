# Add ccache to PATH
export PATH=/usr/lib/ccache:$PATH
export VLR_ROOT=/home/daniel/

export ZOOX_CMAKE_OPTIONS="-j -l4"

# Override roscompile for threading
function zoox-build(){
(
  cd $ROS_WORKSPACE
  pwd
  if [[ "core" == "$1" ]]; then
    catkin_make $ZOOX_CMAKE_OPTIONS 
  elif [[ "all" == "$1" ]]; then
    catkin_make all tests $ZOOX_CMAKE_OPTIONS 
  else
    catkin_make $1 $ZOOX_CMAKE_OPTIONS
  fi
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

