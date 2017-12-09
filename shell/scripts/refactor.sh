#! /usr/bin/env bash

set -euo pipefail

refactor-all() {
  old="$1"
  new="$2"
  find . -not -path '*/\.*' -type f | xargs file | awk '/ASCII text/' | sed 's/\:.*//' | xargs sed -i "s/$old/$new/g"
}

refactor-all "$@"
