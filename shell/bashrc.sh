##01-head.bashrc
# If not running interactively, don't do anything
#case $- in
#    *i*) ;;
#      *) return;;
#esac

if [ -f ~/.commonrc ]; then
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
