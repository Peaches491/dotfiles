#! /usr/bin/env bash
set -euo pipefail

function send_message() {
  local message="${1:-<empty message>}"

  curl -s \
    --form-string "token=aoesy4jvxx4fxknj1zm9rjucjksv6x" \
    --form-string "user=ucnUM6oK52usnBLgCpFfMA2hdJj2WF" \
    --form-string "message=$message" \
    https://api.pushover.net/1/messages.json
}

send_message $@
