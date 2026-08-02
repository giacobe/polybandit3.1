#!/bin/sh
set -eu

cd "$(dirname "$0")"
INSTALL_ROOT=$(pwd)
export INSTALL_ROOT
. "$INSTALL_ROOT/resources.sh"

test_root=$(mktemp -d "${TMPDIR:-/tmp}/polylinux-polybandit.XXXXXX")
trap 'rm -rf "$test_root"' EXIT HUP INT TERM

generate_case() {
    case_name=$1; case_user=$2; case_date=$3
    case_root="$test_root/$case_name"
    USER_ID=$(normalize_email "$case_user")
    currentDate=$case_date
    EXERCISE_CODE=$(exercise_code_from_date "$currentDate")
    SYSTEM_PASSWORD=exercisePassword
    LEVEL_PASSWORD_ROOT=levelPassword
    ANSWER_DIR="$case_root/answers"
    HOME_ROOT="$case_root/home"
    SYSTEM_EVIDENCE_ROOT="$case_root/evidence"
    SKIP_OWNERSHIP=1
    export USER_ID currentDate EXERCISE_CODE SYSTEM_PASSWORD LEVEL_PASSWORD_ROOT \
        ANSWER_DIR HOME_ROOT SYSTEM_EVIDENCE_ROOT SKIP_OWNERSHIP
    rm -rf "$case_root"
    mkdir -p "$ANSWER_DIR" "$HOME_ROOT" "$SYSTEM_EVIDENCE_ROOT"
    levelnumber=1
    while [ "$levelnumber" -le 13 ]; do
        levelToBuild="bandit$levelnumber"
        LEVEL_HOME="$HOME_ROOT/$levelToBuild"
        levelPassword="${LEVEL_PASSWORD_ROOT}${levelnumber}"
        level_HASH=$(printf '%s%s%s%s' "$USER_ID" "$currentDate" "$SYSTEM_PASSWORD" "$levelPassword" | sha256sum | awk '{print $1}')
        export levelnumber levelToBuild LEVEL_HOME levelPassword level_HASH
        mkdir -p "$LEVEL_HOME"
        sh "$INSTALL_ROOT/$levelToBuild.sh"
        levelnumber=$((levelnumber + 1))
    done
}

snapshot_case() {
    root=$1
    find "$root" -type f -exec sha256sum {} \; | sed "s|$root/||" | sort
    find "$root" -type f -exec ls -ld {} \; | awk '{print $1, $5, $NF}' | sed "s|$root/||" | sort
}

echo "generate fixed case A"
generate_case case-a ' Student@Example.EDU ' 2026-08-02
[ "$USER_ID" = student@example.edu ]
[ "$EXERCISE_CODE" = 13527C2 ]

echo "verify all independent reference solvers"
HOME_ROOT="$test_root/case-a/home" ANSWER_DIR="$test_root/case-a/answers" \
SYSTEM_EVIDENCE_ROOT="$test_root/case-a/evidence" VERIFY_SKIP_OWNERSHIP=1 \
    sh "$INSTALL_ROOT/verify.sh"

echo "test level invariants"
[ "$(find "$test_root/case-a/home/bandit5/inhere" -type f | wc -l | tr -d ' ')" -eq 10 ]
[ "$(find "$test_root/case-a/home/bandit6/inhere" -type f -size 205c ! -perm /111 | wc -l | tr -d ' ')" -eq 1 ]
[ "$(find "$test_root/case-a/evidence" -type f -size 21c | wc -l | tr -d ' ')" -eq 1 ]
[ "$(sort "$test_root/case-a/home/bandit9/data.txt" | uniq -u | wc -l | tr -d ' ')" -eq 1 ]

echo "test identical-input repeatability"
snapshot_case "$test_root/case-a" > "$test_root/snapshot-a"
generate_case case-a student@example.edu 2026-08-02
snapshot_case "$test_root/case-a" > "$test_root/snapshot-a-rerun"
cmp "$test_root/snapshot-a" "$test_root/snapshot-a-rerun"

echo "test changed-learner and changed-code variation"
generate_case case-b second.student@example.edu 2026-08-02
! cmp -s "$test_root/case-a/answers/bandit13" "$test_root/case-b/answers/bandit13"
generate_case case-c student@example.edu 2026-08-03
! cmp -s "$test_root/case-a/answers/bandit6" "$test_root/case-c/answers/bandit6"

echo "test email and exercise-code validation"
[ "$(normalize_email '  Mixed.Case@Example.EDU ')" = mixed.case@example.edu ]
validate_email student@example.edu
if validate_email 'not an address'; then die "invalid email accepted"; fi
[ "$(exercise_code_from_date 2026-08-02)" = 13527C2 ]

echo "test answer modes and required-command detection"
find "$test_root/case-a/answers" -type f -exec chmod 600 {} \;
[ -z "$(find "$test_root/case-a/answers" -type f ! -perm 600)" ]
if (command_required definitely-not-a-polylinux-command) >/dev/null 2>&1; then die "missing command accepted"; fi

echo "All deterministic tests passed."
