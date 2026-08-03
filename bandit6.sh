#!/bin/sh
set -eu
. "$INSTALL_ROOT/resources.sh"
answer=$(answer_token 20)
mkdir -p "$LEVEL_HOME/inhere"
layout=$(derive_hex layout)
target_dir=$((10 + $(hex_byte "$layout" 0) % 12))
target_file=$((1 + $(hex_byte "$layout" 1) % 6))
d=10
while [ "$d" -le 21 ]; do
    dir="$LEVEL_HOME/inhere/maybehere$d"; mkdir -p "$dir"
    f=1
    while [ "$f" -le 6 ]; do
        path="$dir/-file$f"
        if [ "$d" -eq "$target_dir" ] && [ "$f" -eq "$target_file" ]; then
            printf '%s\n' "$answer" > "$path"
            awk 'BEGIN { for (i=0;i<184;i++) printf " " }' >> "$path"
        else
            case $(((d + f) % 3)) in
                0) fixture=binary-151.bin ;;
                1) fixture=binary-177.bin ;;
                2) fixture=binary-213.bin ;;
            esac
            cp "$FIXTURE_DIR/$fixture" "$path"
            if [ $(((d + f) % 2)) -eq 0 ]; then chmod 700 "$path"; fi
        fi
        f=$((f + 1))
    done
    d=$((d + 1))
done
write_readme "The answer is in the only human-readable regular file below inhere that is exactly 205 bytes and is not executable.
Answer format: the first line of that file: exactly 20 Base64url characters. Case matters."
record_answer "$answer"
finish_level
