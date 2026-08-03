#!/bin/sh
set -eu
. "$INSTALL_ROOT/resources.sh"
answer=$(answer_token 20)
cp "$FIXTURE_DIR/binary-900.bin" "$LEVEL_HOME/data.txt"
printf '\n====== the\n====== flag\n====== is\n====== %s\n' "$answer" >> "$LEVEL_HOME/data.txt"
cat "$FIXTURE_DIR/binary-900.bin" >> "$LEVEL_HOME/data.txt"
write_readme "The answer is one of the few human-readable strings in data.txt and is preceded by several = characters.
Answer format: exactly 20 Base64url characters. Case matters; omit the = characters."
record_answer "$answer"
finish_level
