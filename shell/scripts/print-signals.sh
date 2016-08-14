#!/bin/bash

trap_with_arg() {
    func="$1" ; shift
    for sig ; do
        trap "$func $sig" "$sig"
    done
}

func_trap() {
    echo Trapped: $1
}

trap_with_arg func_trap INT TERM EXIT

read # Wait so the script doesn't exit.
