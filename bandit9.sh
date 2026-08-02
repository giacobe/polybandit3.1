#!/bin/sh
set -eu
. "$INSTALL_ROOT/resources.sh"
answer=$(answer_token 20)
: > "$LEVEL_HOME/data.txt"
pass=1
while [ "$pass" -le 4 ]; do
    i=0
    while [ "$i" -lt 160 ]; do
        derive_indexed_hex repeated "$i" | cut -c 1-20 >> "$LEVEL_HOME/data.txt"
        printf '\n' >> "$LEVEL_HOME/data.txt"
        i=$((i + 1))
    done
    [ "$pass" -ne 3 ] || printf '%s\n' "$answer" >> "$LEVEL_HOME/data.txt"
    pass=$((pass + 1))
done
write_readme "The answer is the only line in data.txt that occurs exactly once.
Answer format: exactly 20 Base64url characters. Case matters; do not add spaces."
record_answer "$answer"
finish_level
