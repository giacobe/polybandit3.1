#!/bin/sh
set -eu
. "$INSTALL_ROOT/resources.sh"
answer=$(answer_token 20)
: > "$LEVEL_HOME/data.txt"
cat "$FIXTURE_DIR/repeated-lines.txt" "$FIXTURE_DIR/repeated-lines.txt" \
    "$FIXTURE_DIR/repeated-lines.txt" > "$LEVEL_HOME/data.txt"
printf '%s\n' "$answer" >> "$LEVEL_HOME/data.txt"
cat "$FIXTURE_DIR/repeated-lines.txt" >> "$LEVEL_HOME/data.txt"
write_readme "The answer is the only line in data.txt that occurs exactly once.
Answer format: exactly 20 Base64url characters. Case matters; do not add spaces."
record_answer "$answer"
finish_level
