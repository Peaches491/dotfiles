
# pull down tests
function ros-log-latest() {
(
  cd ~/.ros/log
  find ~/.ros/log/*/rosout.log -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "
)
}

function ros-log-dir() {
(
  cd ~/.ros/log
  find ~/.ros/log/* -type d -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "
)
}
