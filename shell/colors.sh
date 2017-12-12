#!/usr/bin/env bash

DOWN_ARROW_SYMBOL=$'\xe2\x86\x93'
RIGHT_ARROW_SYMBOL=$'\xe2\x86\x92'
UP_ARROW_SYMBOL=$'\xe2\x86\x91'
LEFT_ARROW_SYMBOL=$'\xe2\x86\x90'
PLUS_MINUS_SYMBOL=$'±'
X_SYMBOL="✗"
CHECK_SYMBOL="✓"

##51-bash-colors
bash_normal='\e[0m'
bash_reset_color='\e[0m'
bash_blue='\e[0;34m'
bash_bold_blue='\e[1;34m'
bash_underline_blue='\e[4;34m'
bash_background_blue='\e[44m'
bash_black='\e[0;30m'
bash_bold_black='\e[1;30m'
bash_underline_black='\e[4;30m'
bash_background_black='\e[40m'
bash_yellow='\e[0;33m'
bash_bold_yellow='\e[;33m'
bash_underline_yellow='\e[4;33m'
bash_background_yellow='\e[43m'
bash_cyan='\e[0;36m'
bash_bold_cyan='\e[1;36m'
bash_underline_cyan='\e[4;36m'
bash_background_cyan='\e[46m'
bash_magenta='\e[0;35m'
bash_bold_magenta='\e[1;35m'
bash_underline_magenta='\e[4;35m'
bash_background_magenta='\e[45m'
bash_green='\e[0;32m'
bash_bold_green='\e[1;32m'
bash_underline_green='\e[4;32m'
bash_background_green='\e[42m'
bash_white='\e[0;37m'
bash_bold_white='\e[1;37m'
bash_underline_white='\e[4;37m'
bash_background_white='\e[47m'
bash_red='\e[0;31m'
bash_bold_red='\e[1;31m'
bash_underline_red='\e[4;31m'
bash_background_red='\e[41m'
bash_orange='\e[01;31m'
bash_bold_orange='\e[01;31m'
bash_underline_orange='\e[4;31m'
bash_background_orange='\e[41m'

function nonprint {
    echo "\[$@\]"
}
