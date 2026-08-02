#!/bin/sh

die() { echo "ERROR: $*" >&2; exit 1; }
command_required() { command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"; }

normalize_email() {
    printf '%s' "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]'
}

validate_email() {
    value=$1
    [ -n "$value" ] || return 1
    [ "${#value}" -le 254 ] || return 1
    case "$value" in *[!abcdefghijklmnopqrstuvwxyz0123456789.!#$%\&\'*+/=?^_\`{|}~@-]*|*' '*|*'@@'*|@*|*@|*.*@*.*@*) return 1 ;; esac
    local_part=${value%%@*}
    domain_part=${value#*@}
    [ "$local_part" != "$value" ] || return 1
    case "$domain_part" in *'@'*|.*|*.|*..*|-*|*-) return 1 ;; esac
    case "$domain_part" in *.*) return 0 ;; *) return 1 ;; esac
}

validate_iso_date() {
    case "$1" in
        [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) return 0 ;;
        *) return 1 ;;
    esac
}

exercise_code_from_date() {
    decimal=$(printf '%s' "$1" | tr -d '-')
    printf '%X\n' "$decimal"
}

derive_hex() { printf '%s:%s' "$level_HASH" "$1" | sha256sum | awk '{print $1}'; }
derive_indexed_hex() { printf '%s:%s:%s' "$level_HASH" "$1" "$2" | sha256sum | awk '{print $1}'; }

hex_byte() {
    hex=$1; index=$2; start=$((index * 2 + 1))
    pair=$(printf '%s' "$hex" | cut -c "$start-$((start + 1))")
    printf '%d\n' "$((0x$pair))"
}

answer_token() {
    length=$1
    printf '%s' "$(derive_hex answer)" | base64 | tr -d '\r\n=' | tr '+/' '-_' | cut -c "1-$length"
}

write_readme() {
    instructions=$1
    {
        echo "Exercise code: $EXERCISE_CODE"
        echo "Participant: $USER_ID"
        echo "Level: $levelToBuild"
        echo "************************************************************************"
        printf '%s\n' "$instructions"
        echo "************************************************************************"
        echo "Save the exercise code and this level's answer for the submission form."
    } > "$LEVEL_HOME/README.txt"
}

record_answer() {
    printf '%s\n' "$1" > "$ANSWER_DIR/$levelToBuild"
    chmod 600 "$ANSWER_DIR/$levelToBuild"
}

finish_level() {
    [ "${SKIP_OWNERSHIP:-0}" -eq 1 ] && return
    chown -R "$levelToBuild:$levelToBuild" "$LEVEL_HOME"
    chmod -R o-rwx "$LEVEL_HOME"
}

make_binary_file() {
    path=$1; size=$2; label=$3
    : > "$path"
    round=0
    while [ "$(wc -c < "$path")" -lt "$size" ]; do
        derive_indexed_hex "$label" "$round" | xxd -r -p >> "$path"
        round=$((round + 1))
    done
    head -c "$size" "$path" > "$path.tmp"
    mv "$path.tmp" "$path"
}
