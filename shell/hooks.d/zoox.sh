# Add ccache to PATH
export PATH=/usr/lib/ccache:$PATH
export VLR_ROOT=/home/daniel/


# Override roscompile for threading
function zoox-build(){
(
  cd $ROS_WORKSPACE
  pwd
  if [ "core" -eq "$1" ]; then
    catkin_make -j -l8
  elif [ "all" -eq "$1" ]; then
    catkin_make all tests -j -l8
  else
    catkin_make $1 -j -l8
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

