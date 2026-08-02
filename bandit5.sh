#!/bin/sh
set -eu
. "$INSTALL_ROOT/resources.sh"
answer=$(answer_token 20)
mkdir -p "$LEVEL_HOME/inhere"
target=$(( $(hex_byte "$(derive_hex layout)" 0) % 10 ))
i=0
while [ "$i" -lt 10 ]; do
    path="$LEVEL_HOME/inhere/-file$(printf '%02d' "$i")"
    if [ "$i" -eq "$target" ]; then printf '%s\n' "$answer" > "$path"; else make_binary_file "$path" "$((96 + i))" "noise-$i"; fi
    i=$((i + 1))
done
write_readme "The answer is stored in the only human-readable file in the inhere directory. Use file to classify the candidates.
Answer format: exactly 20 Base64url characters. Case matters; do not add spaces."
record_answer "$answer"
finish_level
