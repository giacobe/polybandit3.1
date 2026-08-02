#!/bin/sh
set -eu
. "$INSTALL_ROOT/resources.sh"
answer=$(answer_token 20)
mkdir -p "$LEVEL_HOME/inhere"
printf '%s\n' "$answer" > "$LEVEL_HOME/inhere/.hidden"
printf 'ordinary record\n' > "$LEVEL_HOME/inhere/visible.txt"
write_readme "The answer is stored in a hidden file in the inhere directory.
Answer format: exactly 20 Base64url characters. Case matters; do not add spaces."
record_answer "$answer"
finish_level
