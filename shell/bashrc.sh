##01-head.bashrc
# If not running interactively, don't do anything
#case $- in
#    *i*) ;;
#      *) return;;
#esac

if [ -f ~/.commonrc ]; then

   PS1_lbrace="${fg_blue}[${reset_color}"
   PS1_rbrace="${fg_blue}]${reset_color}"
   PS1_vbar="${fg_green}|${reset_color}"
   PS1_at="${fg_white}@${reset_color}"
   PS1_rangle="${fg_white}>${reset_color}"
   PS1_name="${fg_yellow}${SH_name}${reset_color}"
   PS1_host="${fg_white}${SH_host}${reset_color}"
   PS1_time="${fg_orange}${SH_time}${reset_color}"
   PS1_date="${fg_magenta}${SH_date}${reset_color}"
   PS1_pwd="${fg_blue}${SH_pwd}${reset_color}"
   PS1_priv="${fg_white}${SH_priv}${reset_color}"

   source ~/.commonrc
fi

##02-shellopt.bashrc
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

#correct minor errors in directory spelling
shopt -s cdspell

#use extended pattern matching features
shopt -s extglob

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignorespace:ignoredups
# append to the history file, don't overwrite it
shopt -s histappend
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000
HISTIGNORE='l:ll:lll:llll:ls:exit'


##50-colors.bashrc
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi


##89-other.bashrc
# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


# Fix auto-complete with sudo prefix
if [ "$PS1" ]; then
  complete -cf sudo
fi
