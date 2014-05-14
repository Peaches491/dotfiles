SCM_SYMBOL=$'±'
SCM_DIRTY_SYMBOL="${red}✗"
SCM_CLEAN_SYMBOL="${green}✓"

DOWN_ARROW_SYMBOL=$'\xe2\x86\x93'
RIGHT_ARROW_SYMBOL=$'\xe2\x86\x92'
UP_ARROW_SYMBOL=$'\xe2\x86\x91'
LEFT_ARROW_SYMBOL=$'\xe2\x86\x90'

function git_prompt_vars {
  local status="$(git status -bs --porcelain 2> /dev/null)"

  local ref=$(git symbolic-ref HEAD 2> /dev/null)
  SCM_BRANCH=${ref#refs/heads/}
  SCM_CHANGE=$(git rev-parse --short HEAD 2>/dev/null)
  if [ -z $SCM_BRANCH ]; then
	SCM_HEAD=$SCM_CHANGE
  else
	SCM_HEAD="$SCM_BRANCH${normal}:${purple}$SCM_CHANGE"
  fi

  SCM_GIT_AHEAD=''
  SCM_GIT_BEHIND=''
  local ahead_re='.+ahead ([0-9]+).+'
  local behind_re='.+behind ([0-9]+).+'
  [[ "${status}" =~ ${ahead_re} ]] && SCM_GIT_AHEAD="${BASH_REMATCH[1]}"
  [[ "${status}" =~ ${behind_re} ]] && SCM_GIT_BEHIND="${BASH_REMATCH[1]}"

  SCM_GIT_STASH_COUNT="$(git stash list 2> /dev/null | wc -l | tr -d ' ')"
  SCM_GIT_STAGED_COUNT="$(tail -n +2 <<< "${status}" | grep -v ^[[:space:]?]  | wc -l | tr -d ' ')"
  SCM_GIT_UNSTAGED_COUNT="$(tail -n +2 <<< "${status}" | grep ^.[^[:space:]?]  | wc -l | tr -d ' ')"
  SCM_GIT_UNTRACKED_COUNT="$(tail -n +2 <<< "${status}" | grep ^??  | wc -l | tr -d ' ')"
}
function scm {
  if which git &> /dev/null && [[ -n "$(git rev-parse HEAD 2> /dev/null)" ]]; then
	git_prompt_vars
	SCM="${green} |${green}$SCM_HEAD"
	if [[ $SCM_GIT_STAGED_COUNT -gt 0 || $SCM_GIT_UNSTAGED_COUNT -gt 0 || $SCM_GIT_UNTRACKED_COUNT -gt 0 ]]; then
		SCM="$SCM ${red}("
		[[ $SCM_GIT_STAGED_COUNT -gt 0 ]] && SCM="$SCM${green}+"
		[[ $SCM_GIT_UNSTAGED_COUNT -gt 0 ]] && SCM="$SCM${red}*"
		[[ $SCM_GIT_UNTRACKED_COUNT -gt 0 ]] && SCM="$SCM${cyan}?"
		SCM="$SCM${red})"
	else
		SCM="$SCM $SCM_CLEAN_SYMBOL"
	fi
	[[ $SCM_GIT_BEHIND -gt 0 ]] && SCM=" $SCM ${red}$DOWN_ARROW_SYMBOL$SCM_GIT_BEHIND"
	[[ $SCM_GIT_AHEAD -gt 0 && $SCM_GIT_BEHIND -eq 0 ]] && SCM="$SCM${cyan}"
	[[ $SCM_GIT_AHEAD -gt 0 ]] && SCM="$SCM $UP_ARROW_SYMBOL$SCM_GIT_AHEAD"
	[[ $SCM_GIT_STASH_COUNT -gt 0 ]] && SCM="$SCM ${yellow}(stash: $SCM_GIT_STASH_COUNT)"
	SCM="$SCM${green}|"
  else SCM=""
  fi
}


PROMPT_SYMBOL="${normal}\$"
PROMPT_FORMAT="${normal}"

USERNAME="${yellow}\u"
HOST="${normal}@\h"
WD="${blue}[\w]"
TIME="${orange}\t"


function prompt_command() {
	EXIT_STATUS=$?
	[ -n "$TMUX" ] && tmux_env_update
	scm
	
	if [ $(jobs | wc -l) = 0 ]; then
		JOBS=
	else
		JOBS=`jobs -l | awk "{ if(NR != 1) {printf \\" : \\"} if(\\$3 == \\"Running\\") {printf \\":green:\\"} else {printf \\":red:\\"} {printf \\$1 \\" \\" \\$2 \\" \\" \\$4 \\":normal:\\"} }"`
		JOBS="$(echo $JOBS | sed 's/:green:/\\[\\e[0;32m\\]/g' | sed 's/:red:/\\[\\e[0;31m\\]/g' | sed 's/:normal:/\\[\\e[0m\\]/g')"
		JOBS="$JOBS\n"
	fi
	
	if [ $EXIT_STATUS == 0 ]; then
		EXIT_CODE=
	else
		EXIT_CODE="${white}${background_red}!!! Exited: $EXIT_STATUS !!!"
	fi

	PS1="\n$JOBS$USERNAME$HOST $WD$SCM $TIME $EXIT_CODE${normal}\n ${normal}$PROMPT_SYMBOL $PROMPT_FORMAT"
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