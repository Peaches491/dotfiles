
##11-reload.bashrc
function dotfiles(){
(
  cd ~/.dotfiles
  git pull
  ./install.sh
  source ~/.bashrc
)
}

##12-catkin_make
function roscompile(){
(
  cd $ROS_WORKSPACE
  pwd
  catkin_make
)
}

function roscheck(){
(
  printenv | grep ROS
)
}

##70-status.bashrc
function s()
{
  pwd;
  echo
  l;
  if which git &> /dev/null && [[ -n "$(git rev-parse HEAD 2> /dev/null)" ]]; then
    echo
    git st;
  fi

}


##90-archives.bashrc
function extract()      # Handy Extract Program
{
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1     ;;
            *.tar.gz)    tar xvzf $1     ;;
            *.bz2)       bunzip2 $1      ;;
            *.rar)       unrar x $1      ;;
            *.gz)        gunzip $1       ;;
            *.tar)       tar xvf $1      ;;
            *.tbz2)      tar xvjf $1     ;;
            *.tgz)       tar xvzf $1     ;;
            *.zip)       unzip $1        ;;
            *.Z)         uncompress $1   ;;
            *.7z)        7z x $1         ;;
            *)           echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}


# Creates an archive (*.tar.gz) from given directory.
function maketar() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }


# Create a ZIP archive of a file or folder.
function makezip() { zip -r "${1%%/}.zip" "$1" ; }

# Process monitoring commands
function myps() { ps $@ -u $USER -o pid,%cpu,%mem,bsdtime,command ; }
function pstree() { myps f | awk '!/awk/ && $0~var' var=${1:-".*"} ; }

# Run scripts from script hook directories
run_scripts()
{
    for script in $1/*; do

        # skip non-executable snippets
        [ -x "$script" ] || continue

        # execute $script in the context of the current shell
        . $script
    done
}



##85-prompt
SCM_SYMBOL=$PLUS_MINUS_SYMBOL
SCM_DIRTY_SYMBOL="${fg_red}$X_SYMBOL"
SCM_CLEAN_SYMBOL="${fg_green}$CHECK_SYMBOL"

function git_prompt_vars {
  local stat="$(git status -bs --porcelain 2> /dev/null)"
  local status_first_line="$(head -n1 <<< "${stat}")"

  local ref=$(git symbolic-ref HEAD 2> /dev/null)
  SCM_BRANCH=${ref#refs/heads/}
  SCM_CHANGE=$(git rev-parse --short HEAD 2>/dev/null)

  SCM_GIT_AHEAD=''
  SCM_GIT_BEHIND=''
  local ahead_re='.+ahead ([0-9]+).+'
  local behind_re='.+behind ([0-9]+).+'
  [[ "${status_first_line}" =~ ${ahead_re} ]] && SCM_GIT_AHEAD="${BASH_REMATCH[1]}"
  [[ "${status_first_line}" =~ ${behind_re} ]] && SCM_GIT_BEHIND="${BASH_REMATCH[1]}"

  SCM_GIT_UPSTREAM_REMOTE=''
  SCM_GIT_UPSTREAM_BRANCH=''
  local upstream_re='.+\.\.\.([[:print:]]+)/([^[:space:]]+)'
  [[ "${status_first_line}" =~ ${upstream_re} ]] && SCM_GIT_UPSTREAM_REMOTE="${BASH_REMATCH[1]}" && SCM_GIT_UPSTREAM_BRANCH="${BASH_REMATCH[2]}"

  SCM_GIT_STASH_COUNT="$(git stash list 2> /dev/null | wc -l | tr -d ' ')"
  SCM_GIT_STAGED_COUNT="$(tail -n +2 <<< "${stat}" | grep -v ^[[:space:]?]  | wc -l | tr -d ' ')"
  SCM_GIT_UNSTAGED_COUNT="$(tail -n +2 <<< "${stat}" | grep ^.[^[:space:]?]  | wc -l | tr -d ' ')"
  SCM_GIT_UNTRACKED_COUNT="$(tail -n +2 <<< "${stat}" | grep ^??  | wc -l | tr -d ' ')"


  if [ -z $SCM_BRANCH ]; then
    SCM_HEAD="${fg_green}$SCM_CHANGE"
  else
    SCM_HEAD="${fg_green}$SCM_BRANCH"
	if [ -z $SCM_GIT_UPSTREAM_REMOTE ]; then
    SCM_HEAD="$SCM_HEAD${fg_cyan}(~)"
	elif [ "$SCM_GIT_UPSTREAM_BRANCH" == "$SCM_BRANCH" ]; then
    SCM_HEAD="$SCM_HEAD${fg_cyan}($SCM_GIT_UPSTREAM_REMOTE)"
	else
    SCM_HEAD="$SCM_HEAD${fg_cyan}($SCM_GIT_UPSTREAM_REMOTE/$SCM_GIT_UPSTREAM_BRANCH)"
	fi
    SCM_HEAD="$SCM_HEAD${reset_color}:${fg_magenta}$SCM_CHANGE"
  fi
}

function scm {
  if which git &> /dev/null && [[ -n "$(git rev-parse HEAD 2> /dev/null)" ]]; then
	git_prompt_vars
	SCM="${fg_green}|$SCM_HEAD"
	if [[ $SCM_GIT_STAGED_COUNT -gt 0 || $SCM_GIT_UNSTAGED_COUNT -gt 0 || $SCM_GIT_UNTRACKED_COUNT -gt 0 ]]; then
		SCM="$SCM ${fg_red}("
		[[ $SCM_GIT_STAGED_COUNT -gt 0 ]] && SCM="$SCM${fg_green}+"
		[[ $SCM_GIT_UNSTAGED_COUNT -gt 0 ]] && SCM="$SCM${fg_red}*"
		[[ $SCM_GIT_UNTRACKED_COUNT -gt 0 ]] && SCM="$SCM${fg_cyan}?"
		SCM="$SCM${fg_red})"
	else
		SCM="$SCM $SCM_CLEAN_SYMBOL"
	fi
	[[ $SCM_GIT_BEHIND -gt 0 ]] && SCM="$SCM ${fg_red}$DOWN_ARROW_SYMBOL$SCM_GIT_BEHIND"
	[[ $SCM_GIT_AHEAD -gt 0 && $SCM_GIT_BEHIND -eq 0 ]] && SCM="$SCM${fg_cyan}"
	[[ $SCM_GIT_AHEAD -gt 0 ]] && SCM="$SCM $UP_ARROW_SYMBOL$SCM_GIT_AHEAD"
	[[ $SCM_GIT_STASH_COUNT -gt 0 ]] && SCM="$SCM ${fg_yellow}(stash: $SCM_GIT_STASH_COUNT)"
	SCM="$SCM${fg_green}|"
  else SCM=""
  fi
}

function prompt_command() {
  EXIT_STATUS=$?

  VENV_PROMPT=
  SSH_PROMPT=
  JOBS=
  DIR_STACK=
  EXIT_CODE=

  if [ "$VIRTUAL_ENV" ]; then
    VENV_PROMPT="${fg_green}|${fg_white}venv ${fg_blue}$VIRTUAL_ENV${fg_green}|"
  fi

  if [ "$SSH_CONNECTION" ]; then
    SSH_PROMPT="${fg_green}|${fg_white}ssh ${fg_blue}$SSH_CONNECTION${fg_green}|"
  fi

  JOBS="$(jobs -l | perl -pe 's|(.+)Running\s+|\\[\\e[0;32m\\]\1 |g;' -pe 's|(.+)Stopped\s+|\\[\\e[0;31m\\]\1 |g;' -pe 's|(.+)Killed\s+|\\[\\e[0;35m\\]\1 |g;')"

  scm
  if [[ "$(dirs | wc -w)" -gt "1" ]]; then
    DIR_STACK=" ${fg_cyan}$(dirs | wc -w)"
  fi

  if [[ $EXIT_STATUS != 0 ]]; then
    EXIT_CODE="${fg_bold_white}${fg_background_red}!!! Exited: $EXIT_STATUS !!!"
  fi

  nl="
"
  PS1=$nl
  PS1="$PS1${fg_yellow}${PS1_name}${reset_color}@"
  PS1="$PS1${PS1_host} ${fg_blue}"
  PS1="$PS1${PS1_lbrace}${PS1_pwd}${DIR_STACK}${fg_blue}${PS1_rbrace} "
  PS1="$PS1${fg_bold_red}${PS1_time} "
  PS1="$PS1$EXIT_CODE${reset_color}$nl"
  PS1="$PS1 ${reset_color}$PS1_priv "

  if [[ ! -z "$VENV_PROMPT" ]]; then
    PS1="$nl$VENV_PROMPT$PS1"
  fi

  if [[ ! -z "$SSH_PROMPT" ]]; then
    PS1="$nl$SSH_PROMPT$PS1"
  fi

  if [[ ! -z "$SCM" ]]; then
    PS1="$nl$SCM$PS1"
  fi

  if [[ ! -z "$JOBS" ]]; then
    PS1="$nl$JOBS$PS1"
  fi

  # set title bar
  case "$TERM" in
    xterm*|rxvt*)
      PS1="\[\e]0;\u@\h: \w\a\]$PS1"
      ;;
      *)
    ;;
  esac
  export PS1=$PS1
}


function inotifyrun {
  FORMAT=$(echo -e "\033[1;33m%w%f\033[0m written")
  "$@"
  while inotifywait -qre close_write --format "$FORMAT" --exclude '(/4913|\.sw.)$' .
  do
    "$@"
    echo ""
  done
}
