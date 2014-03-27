SCM_SYMBOL=$'±'
SCM_DIRTY_SYMBOL="${red}✗"
SCM_CLEAN_SYMBOL="${green}✓"

RIGHT_ARROW_SYMBOL=$'\xe2\x86\x92'

PROMPT_SYMBOL="${normal}\$"
PROMPT_FORMAT="${normal}"

USERNAME="${yellow}\u"
HOST="${normal}\h"
WD="${blue}[\w]"


function git_prompt_vars {
  local status="$(git status -bs --porcelain 2> /dev/null)"
  if [[ -n "$(grep -v ^# <<< "${status}")" ]]; then #if there are lines that don't begin with #
    SCM_DIRTY=1
    SCM_STATUS_SYMBOL=$SCM_DIRTY_SYMBOL
  else
    SCM_DIRTY=0
    SCM_STATUS_SYMBOL=$SCM_CLEAN_SYMBOL
  fi

  local ref=$(git symbolic-ref HEAD 2> /dev/null)
  SCM_BRANCH=${ref#refs/heads/}
  SCM_CHANGE=$(git rev-parse HEAD 2>/dev/null)
  if [ -z $SCM_BRANCH ]; then
	SCM_HEAD=$SCM_CHANGE
  else
	SCM_HEAD=$SCM_BRANCH
  fi

  SCM_GIT_AHEAD=''
  SCM_GIT_BEHIND=''
  local ahead_re='.+ahead ([0-9]+).+'
  local behind_re='.+behind ([0-9]+).+'
  [[ "${status}" =~ ${ahead_re} ]] && SCM_GIT_AHEAD="${BASH_REMATCH[1]}"
  [[ "${status}" =~ ${behind_re} ]] && SCM_GIT_BEHIND="${BASH_REMATCH[1]}"

  SCM_GIT_STASH_COUNT="$(git stash list 2> /dev/null | wc -l | tr -d ' ')"
}
function scm {
  if which git &> /dev/null && [[ -n "$(git symbolic-ref HEAD 2> /dev/null)" ]]; then
	git_prompt_vars
	SCM="${green}|${green}$SCM_HEAD $SCM_STATUS_SYMBOL${green}"
	SCM="$SCM|"
  else SCM=""
  fi
}


function prompt_command() {
	EXIT_STATUS=$?
	scm
	
	if [ $(jobs | wc -l) = 0 ]; then
		JOBS=
	else
		LAST_JOB=`jobs | awk '/^\[[0-9]+\]\+/ {print $3}'`
		JOBS="${cyan}[\j∴$LAST_JOB]"
	fi
	
	if [ $EXIT_STATUS == 0 ]; then
		EXIT_CODE=
	else
		EXIT_CODE="${white}${background_red}Exited: $EXIT_STATUS"
	fi

	PS1="\n$USERNAME@$HOST $WD $SCM $JOBS $EXIT_CODE\n$PROMPT_SYMBOL $PROMPT_FORMAT"
	# set title bar
	case "$TERM" in
	    xterm*|rxvt*)
		PS1="\[\e]0;\u@\h: \w\a\]$PS1"
		;;
	    *)
		;;
	esac
	
}

PROMPT_COMMAND=prompt_command;
