#!/bin/sh
set -eu
. "$INSTALL_ROOT/resources.sh"
answer=$(answer_token 20)
printf 'the answer for this level is %s\n' "$answer" | tr 'A-Za-z' 'N-ZA-Mn-za-m' > "$LEVEL_HOME/data.txt"
write_readme "The answer is stored in data.txt. Every uppercase and lowercase letter has been rotated by 13 positions.
Answer format: exactly 20 Base64url characters. Case matters; submit only the decoded value after the words is."
finish_level
