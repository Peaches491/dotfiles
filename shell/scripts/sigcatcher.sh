#!/usr/bin/env sh

/bin/kill -l | tr ' ' '\n' |
while read signal; do
    cat <<END_OF_FUNCTION
handle_$signal () {
  echo "Caught $signal"
}

trap 'handle_$signal' $signal

END_OF_FUNCTION
done >/tmp/sigcatcher.sh

echo 'echo "$$"; eval $@' >>/tmp/sigcatcher.sh

eval sh /tmp/sigcatcher.sh "$@"
