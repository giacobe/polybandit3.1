#!/bin/sh
set -eu
. "$INSTALL_ROOT/resources.sh"
answer=$(answer_token 20)
location=$((10 + $(hex_byte "$(derive_hex layout)" 0) % 44))
awk -v location="$location" -v answer="$answer" '
    { print }
    NR == location { print "millionth " answer }
' "$FIXTURE_DIR/text-records.txt" > "$LEVEL_HOME/data.txt"
write_readme "The answer is stored in data.txt next to the word millionth.
Answer format: the 20-character value following millionth. Case matters."
record_answer "$answer"
finish_level
