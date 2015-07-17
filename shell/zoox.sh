
_zoox() 
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="build-all build-core build-tests download-tests"

        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
}
complete -F _zoox zoox
