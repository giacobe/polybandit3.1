#!/bin/sh
set -eu
. "$INSTALL_ROOT/resources.sh"
answer=$(answer_token 20)
location=$((80 + $(hex_byte "$(derive_hex layout)" 0) % 120))
: > "$LEVEL_HOME/data.txt"
i=0
while [ "$i" -lt 240 ]; do
    printf 'record-%03d %s\n' "$i" "$(derive_indexed_hex records "$i" | cut -c 1-24)" >> "$LEVEL_HOME/data.txt"
    [ "$i" -ne "$location" ] || printf 'millionth %s\n' "$answer" >> "$LEVEL_HOME/data.txt"
    i=$((i + 1))
done
write_readme "The answer is stored in data.txt next to the word millionth.
Answer format: the 20-character value following millionth. Case matters."
record_answer "$answer"
finish_level
