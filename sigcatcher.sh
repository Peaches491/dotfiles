handle_HUP () {
  echo "Caught HUP"
  exit
}

trap 'handle_HUP' HUP

handle_INT () {
  echo "Caught INT"
  exit
}

trap 'handle_INT' INT

handle_QUIT () {
  echo "Caught QUIT"
  exit
}

trap 'handle_QUIT' QUIT

handle_ILL () {
  echo "Caught ILL"
  exit
}

trap 'handle_ILL' ILL

handle_TRAP () {
  echo "Caught TRAP"
  exit
}

trap 'handle_TRAP' TRAP

handle_ABRT () {
  echo "Caught ABRT"
  exit
}

trap 'handle_ABRT' ABRT

handle_BUS () {
  echo "Caught BUS"
  exit
}

trap 'handle_BUS' BUS

handle_FPE () {
  echo "Caught FPE"
  exit
}

trap 'handle_FPE' FPE

handle_KILL () {
  echo "Caught KILL"
  exit
}

trap 'handle_KILL' KILL

handle_USR1 () {
  echo "Caught USR1"
  exit
}

trap 'handle_USR1' USR1

handle_SEGV () {
  echo "Caught SEGV"
  exit
}

trap 'handle_SEGV' SEGV

handle_USR2 () {
  echo "Caught USR2"
  exit
}

trap 'handle_USR2' USR2

handle_PIPE () {
  echo "Caught PIPE"
  exit
}

trap 'handle_PIPE' PIPE

handle_ALRM () {
  echo "Caught ALRM"
  exit
}

trap 'handle_ALRM' ALRM

handle_TERM () {
  echo "Caught TERM"
  exit
}

trap 'handle_TERM' TERM

handle_STKFLT () {
  echo "Caught STKFLT"
  exit
}

trap 'handle_STKFLT' STKFLT

handle_CHLD () {
  echo "Caught CHLD"
  exit
}

trap 'handle_CHLD' CHLD

handle_CONT () {
  echo "Caught CONT"
  exit
}

trap 'handle_CONT' CONT

handle_STOP () {
  echo "Caught STOP"
  exit
}

trap 'handle_STOP' STOP

handle_TSTP () {
  echo "Caught TSTP"
  exit
}

trap 'handle_TSTP' TSTP

handle_TTIN () {
  echo "Caught TTIN"
  exit
}

trap 'handle_TTIN' TTIN

handle_TTOU () {
  echo "Caught TTOU"
  exit
}

trap 'handle_TTOU' TTOU

handle_URG () {
  echo "Caught URG"
  exit
}

trap 'handle_URG' URG

handle_XCPU () {
  echo "Caught XCPU"
  exit
}

trap 'handle_XCPU' XCPU

handle_XFSZ () {
  echo "Caught XFSZ"
  exit
}

trap 'handle_XFSZ' XFSZ

handle_VTALRM () {
  echo "Caught VTALRM"
  exit
}

trap 'handle_VTALRM' VTALRM

handle_PROF () {
  echo "Caught PROF"
  exit
}

trap 'handle_PROF' PROF

handle_WINCH () {
  echo "Caught WINCH"
  exit
}

trap 'handle_WINCH' WINCH

handle_POLL () {
  echo "Caught POLL"
  exit
}

trap 'handle_POLL' POLL

handle_PWR () {
  echo "Caught PWR"
  exit
}

trap 'handle_PWR' PWR

handle_SYS () {
  echo "Caught SYS"
  exit
}

trap 'handle_SYS' SYS

echo "$$"; sleep 600
