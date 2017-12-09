#/usr/bin/env bash

#set -euo pipefail

encryptfs_dir=$HOME/.encryptfs

if [ -d $encryptfs_dir ]; then
    if tmux ls 2>&1 >/dev/null; then
      # tmux is still running, do not auto-unmount
      rm -f $encryptfs_dir/auto-umount
    else
      # no tmux server, auto-unmount is OK.
      touch $encryptfs_dir/auto-umount
    fi
fi

