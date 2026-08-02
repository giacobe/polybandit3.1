#!/bin/sh
set -eu
. "$INSTALL_ROOT/resources.sh"
answer=$(answer_token 20)
make_binary_file "$LEVEL_HOME/data.txt" 900 prefix
printf '\n====== the\n====== flag\n====== is\n====== %s\n' "$answer" >> "$LEVEL_HOME/data.txt"
make_binary_file "$LEVEL_HOME/suffix.bin" 900 suffix
cat "$LEVEL_HOME/suffix.bin" >> "$LEVEL_HOME/data.txt"
rm "$LEVEL_HOME/suffix.bin"
write_readme "The answer is one of the few human-readable strings in data.txt and is preceded by several = characters.
Answer format: exactly 20 Base64url characters. Case matters; omit the = characters."
record_answer "$answer"
finish_level
