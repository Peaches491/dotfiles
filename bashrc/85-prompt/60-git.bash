function git_prompt_vars {
  local status="$(git status -bs --porcelain 2> /dev/null)"

  local ref=$(git symbolic-ref HEAD 2> /dev/null)
  SCM_BRANCH=${ref#refs/heads/}
  SCM_CHANGE=$(git rev-parse --short HEAD 2>/dev/null)

  SCM_GIT_AHEAD=''
  SCM_GIT_BEHIND=''
  local ahead_re='.+ahead ([0-9]+).+'
  local behind_re='.+behind ([0-9]+).+'
  [[ "${status}" =~ ${ahead_re} ]] && SCM_GIT_AHEAD="${BASH_REMATCH[1]}"
  [[ "${status}" =~ ${behind_re} ]] && SCM_GIT_BEHIND="${BASH_REMATCH[1]}"

  SCM_GIT_UPSTREAM_REMOTE=''
  SCM_GIT_UPSTREAM_BRANCH=''
  local upstream_re='.+\.\.\.([a-z]+)/([a-z]+).+'
  [[ "${status}" =~ ${upstream_re} ]] && SCM_GIT_UPSTREAM_REMOTE="${BASH_REMATCH[1]}" && SCM_GIT_UPSTREAM_BRANCH="${BASH_REMATCH[2]}"

  SCM_GIT_STASH_COUNT="$(git stash list 2> /dev/null | wc -l | tr -d ' ')"
  SCM_GIT_STAGED_COUNT="$(tail -n +2 <<< "${status}" | grep -v ^[[:space:]?]  | wc -l | tr -d ' ')"
  SCM_GIT_UNSTAGED_COUNT="$(tail -n +2 <<< "${status}" | grep ^.[^[:space:]?]  | wc -l | tr -d ' ')"
  SCM_GIT_UNTRACKED_COUNT="$(tail -n +2 <<< "${status}" | grep ^??  | wc -l | tr -d ' ')"


  if [ -z $SCM_BRANCH ]; then
	SCM_HEAD="${bash_prompt_green}$SCM_CHANGE"
  else
	SCM_HEAD="${bash_prompt_green}$SCM_BRANCH"
	if [ -z $SCM_GIT_UPSTREAM_REMOTE ]; then
	    SCM_HEAD="$SCM_HEAD${bash_prompt_cyan}(~)"
	elif [ "$SCM_GIT_UPSTREAM_BRANCH" == "$SCM_BRANCH" ]; then
	    SCM_HEAD="$SCM_HEAD${bash_prompt_cyan}($SCM_GIT_UPSTREAM_REMOTE)"
	else
	    SCM_HEAD="$SCM_HEAD${bash_prompt_cyan}($SCM_GIT_UPSTREAM_REMOTE/$SCM_GIT_UPSTREAM_BRANCH)"
	fi
	SCM_HEAD="$SCM_HEAD${bash_prompt_normal}:${bash_prompt_purple}$SCM_CHANGE"
  fi
}

function scm {
  if which git &> /dev/null && [[ -n "$(git rev-parse HEAD 2> /dev/null)" ]]; then
	git_prompt_vars
	SCM="${bash_prompt_green} |$SCM_HEAD"
	if [[ $SCM_GIT_STAGED_COUNT -gt 0 || $SCM_GIT_UNSTAGED_COUNT -gt 0 || $SCM_GIT_UNTRACKED_COUNT -gt 0 ]]; then
		SCM="$SCM ${bash_prompt_red}("
		[[ $SCM_GIT_STAGED_COUNT -gt 0 ]] && SCM="$SCM${bash_prompt_green}+"
		[[ $SCM_GIT_UNSTAGED_COUNT -gt 0 ]] && SCM="$SCM${bash_prompt_red}*"
		[[ $SCM_GIT_UNTRACKED_COUNT -gt 0 ]] && SCM="$SCM${bash_prompt_cyan}?"
		SCM="$SCM${bash_prompt_red})"
	else
		SCM="$SCM $SCM_CLEAN_SYMBOL"
	fi
	[[ $SCM_GIT_BEHIND -gt 0 ]] && SCM=" $SCM ${bash_prompt_red}$DOWN_ARROW_SYMBOL$SCM_GIT_BEHIND"
	[[ $SCM_GIT_AHEAD -gt 0 && $SCM_GIT_BEHIND -eq 0 ]] && SCM="$SCM${bash_prompt_cyan}"
	[[ $SCM_GIT_AHEAD -gt 0 ]] && SCM="$SCM $UP_ARROW_SYMBOL$SCM_GIT_AHEAD"
	[[ $SCM_GIT_STASH_COUNT -gt 0 ]] && SCM="$SCM ${bash_prompt_yellow}(stash: $SCM_GIT_STASH_COUNT)"
	SCM="$SCM${bash_prompt_green}|"
  else SCM=""
  fi
}

