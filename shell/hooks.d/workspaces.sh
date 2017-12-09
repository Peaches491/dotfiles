#!/usr/bin/env bash

#set -uo pipefail

alias errecho='>&2 echo'

command_gen_script="$DOTFILES_ROOT/shell/scripts/workspaces.py"

#workspace_name="${1}"

function export_print {
  name="$1"
  value="${!name}"
  printf "%15s: %s\n" "$name" "$value"
  export "$name=$value"
}

function _workspace_completion {
  cur_word="${COMP_WORDS[COMP_CWORD]}"
  prev_word="${COMP_WORDS[COMP_CWORD-1]}"
  options="$($command_gen_script dump_options --prev $prev_word --cur $cur_word)"
  COMPREPLY=( $( compgen -W "$options" -- $cur_word ) )
  return 0
}

function workspace {
  eval "$($command_gen_script $@)"
}
alias ws='workspace '
alias wscd='workspace cd'
alias wss='workspace source '

complete -F _workspace_completion workspace
complete -F _complete_alias ws
complete -F _complete_alias wscd
complete -F _complete_alias wss

#return 0
