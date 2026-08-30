#!/bin/sh
set -eu
. "$INSTALL_ROOT/resources.sh"
answer=$(answer_token 20)
printf 'the answer for this level is %s\n' "$answer" | base64 > "$LEVEL_HOME/data.txt"
write_readme "The answer is stored in data.txt, which contains Base64-encoded text.
Answer format: exactly 20 Base64url characters. Case matters; submit only the value after the decoded words is."
finish_level
