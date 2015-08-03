
# pull down tests
function ros-log-dir() {
  find ~/.ros/log/* -type d -printf '%T@ %p\n' | 
    sort -n | 
    tail -1 | 
    cut -f2- -d" "
}

function ros-log-latest() {
  echo $(ros-log-dir)/rosout.log
}

