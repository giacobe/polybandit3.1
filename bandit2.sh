#!/bin/sh
set -eu
. "$INSTALL_ROOT/resources.sh"
answer=$(answer_token 20)
printf '%s\n' "$answer" > "$LEVEL_HOME/-"
write_readme "The answer is stored in a file named - in your home directory. Use a pathname that prevents the command from treating - as standard input.
Answer format: exactly 20 Base64url characters. Case matters; do not add spaces."
finish_level
