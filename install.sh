#!/bin/sh
set -eu

cd "$(dirname "$0")"
INSTALL_ROOT=$(pwd)
export INSTALL_ROOT
. "$INSTALL_ROOT/resources.sh"

SYSTEM_PASSWORD=${SYSTEM_PASSWORD:-systemPassword}
LEVEL_PASSWORD_ROOT=${LEVEL_PASSWORD_ROOT:-levelPassword}
currentDate=${CURRENT_DATE:-$(date +%Y-%m-%d)}
export SYSTEM_PASSWORD LEVEL_PASSWORD_ROOT currentDate

NON_INTERACTIVE=0
NO_LOGIN=0
for arg in "$@"; do
    case "$arg" in
        --non-interactive) NON_INTERACTIVE=1 ;;
        --no-login) NO_LOGIN=1 ;;
        *) die "unknown option: $arg" ;;
    esac
done

if [ "$NON_INTERACTIVE" -eq 1 ]; then
    raw_user=${USER_ID:-student@example.edu}
else
    confirmation=n
    while [ "$confirmation" != y ]; do
        printf 'Enter your email address: '
        IFS= read -r raw_user
        normalized=$(normalize_email "$raw_user")
        validate_email "$normalized" || { echo "That address is not valid." >&2; continue; }
        printf 'The exercise will use %s. Is that correct? (y/n) ' "$normalized"
        IFS= read -r confirmation
    done
fi

USER_ID=$(normalize_email "$raw_user")
validate_email "$USER_ID" || die "invalid email address after normalization"
validate_iso_date "$currentDate" || die "CURRENT_DATE must be YYYY-MM-DD"
EXERCISE_CODE=$(exercise_code_from_date "$currentDate")
export USER_ID EXERCISE_CODE

for cmd in adduser awk base64 basename bzip2 cat chmod chown cp cut date \
    dirname file find grep gzip head id mkdir mv passwd printf pwd rm sed \
    sha256sum sort strings su tail tar touch tr uniq wc xxd; do
    command_required "$cmd"
done

mkdir -p /home /var/lib/polybandit/answers /var/lib/polybandit/evidence
chmod 700 /var/lib/polybandit /var/lib/polybandit/answers
ANSWER_DIR=/var/lib/polybandit/answers
SYSTEM_EVIDENCE_ROOT=/var/lib/polybandit/evidence
export ANSWER_DIR SYSTEM_EVIDENCE_ROOT

cp "$INSTALL_ROOT/profile" /etc/profile
for command_file in nextlevel prevlevel; do
    cp "$INSTALL_ROOT/$command_file" "/usr/bin/$command_file"
    chmod 755 "/usr/bin/$command_file"
done

echo "Building 13 PolyBandit levels (exercise code $EXERCISE_CODE)"
levelnumber=1
while [ "$levelnumber" -le 13 ]; do
    levelToBuild="bandit$levelnumber"
    LEVEL_HOME="/home/$levelToBuild"
    levelPassword="${LEVEL_PASSWORD_ROOT}${levelnumber}"
    level_HASH=$(printf '%s%s%s%s' "$USER_ID" "$currentDate" \
        "$SYSTEM_PASSWORD" "$levelPassword" | sha256sum | awk '{print $1}')
    export levelnumber levelToBuild LEVEL_HOME levelPassword level_HASH

    if ! id "$levelToBuild" >/dev/null 2>&1; then
        adduser -D -g "PolyBandit learner" "$levelToBuild"
    fi
    passwd -d "$levelToBuild" >/dev/null 2>&1 || true
    case "$LEVEL_HOME" in
        /home/bandit[1-9]|/home/bandit1[0-3]) rm -rf "$LEVEL_HOME" ;;
        *) die "refusing to reset unexpected home: $LEVEL_HOME" ;;
    esac
    mkdir -p "$LEVEL_HOME"
    rm -f "$SYSTEM_EVIDENCE_ROOT/$levelToBuild.password"
    echo "  $levelToBuild"
    sh "$INSTALL_ROOT/$levelToBuild.sh"
    levelnumber=$((levelnumber + 1))
done

echo "Build complete. Submit all 13 answers through the external answer form."
if [ "$NO_LOGIN" -eq 0 ]; then
    exec su -l bandit1
fi
