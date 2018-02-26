#######################
# Cross-shell variables
#######################
export EDITOR='vim'
alias vim='vim'

export PAGER=less


###########################
# Platform specific aliases
###########################
if [ "$DOTFILES_is_mac" = true ]; then
    alias ls='gls -G -h --color=auto'
    alias dircolors='gdircolors'
else
    alias ls='ls -G -h --color=auto'
fi


#####################
# Cross-shell aliases
#####################
alias -- -='cd -'  # go to the previous directory
alias .....='cd ../../../..'
alias ....='cd ../../..'
alias ...='cd ../..'
alias ..='cd ..'
alias bb='bazel build '
alias bba='bazel build ...'
alias bt='bazel test '
alias bta='bazel test ...'
alias cl='clear'
alias claer='clear'
alias df='df -h'
alias du='du -h'
alias e=$EDITOR
alias cgrep='grep --color=always'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias g='git'
alias gg='git grep'
alias grep-rec='find . -type f -print0 | xargs -0 grep'
alias grep='grep --color=auto'
alias inorun='inotifyrun '
alias killbg='kill $(jobs -p)'  # kill all background tasks
alias l='ls -F'
alias la='ls -al'
alias less='less -R'
alias ll='l -Al'
alias lll='ll -a'
alias llll='lll -i'
alias lr='ll -R'  # Recursive ls
alias lock='DISPLAY=:0 gnome-screensaver-command --lock --activate'
alias unlock='DISPLAY=:0 gnome-screensaver-command --deactivate'
alias mkdir='mkdir -p'  # recursive directory make
alias o='gnome-open'
alias rmtmp='rm -f *~;rm -f .*~'  # delete all file ending in ~ in the current directory
alias sac='eval $(ssh-agent-canonicalize)'
alias stop-asking='echo "ssh-agent" has been superseded by ssh-agent-canonicalize'
alias sshx='ssh -XYC '
alias sudo='sudo '
alias tma='tmux attach -t '
alias tmk='tmux kill-session -t '
alias tml='tmux list-sessions'
alias tmux='tmux -2'
alias tree='tree -Chsu'  # Nice alternative to recursive ls
alias watch='watch  --color  '
alias webserver='python -m SimpleHTTPServer'  # Simple web server
alias what=which
alias when=date
alias where=which
alias which='type -a'
alias venv='source venv/bin/activate'
alias vnc_server='x11vnc -display :0 -noxdamage -rfbauth ~/.vnc/passwd'
alias vnc_server_root='vnc_server -auth /var/run/lightdm/root/:0'
alias xssh='ssh -XYC '
alias ~='cd'


