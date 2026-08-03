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
    sha256sum sleep sort strings su tail tar touch tr uniq wc xxd; do
    command_required "$cmd"
done

for asset in binary-noise-1024.b64 text-records.txt; do
    [ -f "$INSTALL_ROOT/assets/$asset" ] || die "required fixture asset not found: assets/$asset"
done

mkdir -p /home /var/lib/polybandit/answers /var/lib/polybandit/evidence \
    /var/run/polybandit/ready /var/run/polybandit/failed
chmod 755 /var/lib/polybandit /var/lib/polybandit/evidence
chmod 700 /var/lib/polybandit/answers
chmod 755 /var/run/polybandit /var/run/polybandit/ready /var/run/polybandit/failed
ANSWER_DIR=/var/lib/polybandit/answers
SYSTEM_EVIDENCE_ROOT=/var/lib/polybandit/evidence
STATUS_ROOT=/var/run/polybandit
READY_DIR=$STATUS_ROOT/ready
FAILED_DIR=$STATUS_ROOT/failed
FIXTURE_DIR=/tmp/polybandit-fixtures
BUILD_LOG=/var/log/polybandit-build.log
MAX_PARALLEL=${MAX_PARALLEL:-3}
case "$MAX_PARALLEL" in 1|2|3|4) ;; *) die "MAX_PARALLEL must be between 1 and 4" ;; esac
export ANSWER_DIR SYSTEM_EVIDENCE_ROOT STATUS_ROOT READY_DIR FAILED_DIR FIXTURE_DIR

rm -f "$READY_DIR"/bandit* "$FAILED_DIR"/bandit* "$STATUS_ROOT/all-ready" "$STATUS_ROOT/build-failed"
: > "$BUILD_LOG"
prepare_fixture_cache "$FIXTURE_DIR"

cp "$INSTALL_ROOT/profile" /etc/profile
for command_file in nextlevel prevlevel; do
    cp "$INSTALL_ROOT/$command_file" "/usr/bin/$command_file"
    chmod 755 "/usr/bin/$command_file"
done

# Create every account before any concurrent generator uses ownership metadata.
levelnumber=1
while [ "$levelnumber" -le 13 ]; do
    levelToBuild="bandit$levelnumber"
    if ! id "$levelToBuild" >/dev/null 2>&1; then
        adduser -D -g "PolyBandit learner" "$levelToBuild"
    fi
    passwd -d "$levelToBuild" >/dev/null 2>&1 || true
    final_home="/home/$levelToBuild"
    staging_home="/home/.polybandit-build-$levelToBuild"
    case "$final_home:$staging_home" in
        /home/bandit[1-9]:/home/.polybandit-build-bandit[1-9]|\
        /home/bandit1[0-3]:/home/.polybandit-build-bandit1[0-3])
            rm -rf "$final_home" "$staging_home"
            ;;
        *) die "refusing to reset unexpected homes: $final_home $staging_home" ;;
    esac
    rm -f "$SYSTEM_EVIDENCE_ROOT/$levelToBuild.password"
    levelnumber=$((levelnumber + 1))
done

build_one_level() (
    levelnumber=$1
    levelToBuild="bandit$levelnumber"
    final_home="/home/$levelToBuild"
    LEVEL_HOME="/home/.polybandit-build-$levelToBuild"
    levelPassword="${LEVEL_PASSWORD_ROOT}${levelnumber}"
    level_HASH=$(printf '%s%s%s%s' "$USER_ID" "$currentDate" \
        "$SYSTEM_PASSWORD" "$levelPassword" | sha256sum | awk '{print $1}')
    export levelnumber levelToBuild LEVEL_HOME levelPassword level_HASH
    rm -rf "$LEVEL_HOME"
    mkdir -p "$LEVEL_HOME"
    if sh "$INSTALL_ROOT/$levelToBuild.sh" && mv "$LEVEL_HOME" "$final_home"; then
        touch "$READY_DIR/$levelToBuild"
        echo "$levelToBuild ready"
        exit 0
    fi
    rm -rf "$LEVEL_HOME"
    touch "$FAILED_DIR/$levelToBuild"
    echo "$levelToBuild failed" >&2
    exit 1
)

build_all_levels() (
    failures=0
    pids=
    running=0
    levelnumber=1
    while [ "$levelnumber" -le 13 ]; do
        build_one_level "$levelnumber" >> "$BUILD_LOG" 2>&1 &
        pids="$pids $!"
        running=$((running + 1))
        if [ "$running" -eq "$MAX_PARALLEL" ]; then
            for pid in $pids; do wait "$pid" || failures=$((failures + 1)); done
            pids=
            running=0
        fi
        levelnumber=$((levelnumber + 1))
    done
    for pid in $pids; do wait "$pid" || failures=$((failures + 1)); done
    if [ "$failures" -eq 0 ]; then
        touch "$STATUS_ROOT/all-ready"
        echo "All 13 levels ready" >> "$BUILD_LOG"
        exit 0
    fi
    touch "$STATUS_ROOT/build-failed"
    echo "$failures level builds failed" >> "$BUILD_LOG"
    exit 1
)

echo "Preparing 13 PolyBandit levels with up to $MAX_PARALLEL concurrent builds."
echo "Exercise code: $EXERCISE_CODE"
build_all_levels &
SUPERVISOR_PID=$!

if [ "$NO_LOGIN" -eq 1 ]; then
    wait "$SUPERVISOR_PID" || die "one or more level builds failed; see $BUILD_LOG"
    echo "Build complete. Submit all 13 answers through the external answer form."
    exit 0
fi

echo "Waiting for bandit1; later levels will continue preparing in the background."
while [ ! -f "$READY_DIR/bandit1" ]; do
    [ ! -f "$FAILED_DIR/bandit1" ] || die "bandit1 failed to build; see $BUILD_LOG"
    sleep 0.1
done
echo "bandit1 is ready. Other levels may still be preparing."
exec su -l bandit1
