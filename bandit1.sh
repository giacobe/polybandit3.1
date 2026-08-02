#!/bin/sh
set -eu
. "$INSTALL_ROOT/resources.sh"
answer=$(answer_token 20)
printf '%s\n' "$answer" > "$LEVEL_HOME/inhere.txt"
write_readme "The answer is stored in a file named inhere.txt in your home directory.
Answer format: exactly 20 Base64url characters. Case matters; do not add spaces."
record_answer "$answer"
finish_level
