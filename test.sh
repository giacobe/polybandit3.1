#!/bin/sh
set -eu
cd "$(dirname "$0")"
. ./polylinux-common.sh
LAB_ID=polybandit
USER_ID=$(normalize_email ' Student@Example.EDU ')
currentDate=2026-08-30
SYSTEM_PASSWORD=systemPassword
levelPassword=levelPassword1
levelnumber=1
export LAB_ID USER_ID currentDate SYSTEM_PASSWORD levelPassword levelnumber
[ "$USER_ID" = student@example.edu ]
[ "$(exercise_code_from_date "$currentDate")" = 13527DE ]
[ "$(level_seed_v1)" = "$(level_seed_v1)" ]
for n in 1 2 3 4 5 6 7 8 9 10 11 12 13; do sh -n "./bandit$n.sh"; done
sh -n ./install.sh ./resources.sh ./polylinux-common.sh
! grep -R -n -E 'record_answer|ANSWER_DIR|/answers|checklevel' . --exclude-dir=.git --exclude=README.md --exclude=test.sh --exclude=verify.sh

# Exercise each generator through a fresh shell, matching install.sh's
# subprocess boundary. This prevents shared renderer functions from being
# accidentally available only in the parent installer.
test_root="${TMPDIR:-/tmp}/polybandit-generator-test-$$"
trap 'rm -rf "$test_root"' EXIT HUP INT TERM
INSTALL_ROOT=$(pwd)
FIXTURE_DIR="$test_root/polybandit-fixtures"
SYSTEM_EVIDENCE_ROOT="$test_root/evidence"
EXERCISE_CODE=$(exercise_code_from_date "$currentDate")
SKIP_OWNERSHIP=1
export INSTALL_ROOT FIXTURE_DIR SYSTEM_EVIDENCE_ROOT EXERCISE_CODE SKIP_OWNERSHIP
mkdir -p "$SYSTEM_EVIDENCE_ROOT"
. ./resources.sh
prepare_fixture_cache "$FIXTURE_DIR"
for n in 1 2 3 4 5 6 7 8 9 10 11 12 13; do
    levelnumber=$n
    levelToBuild="bandit$n"
    levelPassword="levelPassword$n"
    level_HASH=$(level_seed_v1)
    LEVEL_HOME="$test_root/$levelToBuild"
    export levelnumber levelToBuild levelPassword level_HASH LEVEL_HOME
    mkdir -p "$LEVEL_HOME"
    sh "./bandit$n.sh"
    [ -s "$LEVEL_HOME/README.txt" ]
    awk 'length($0) != 40 { exit 1 }' "$LEVEL_HOME/README.txt"
    [ "$(grep -c '^\* Level:' "$LEVEL_HOME/README.txt")" -eq 1 ]
    [ "$(grep -c '^\* Participant:' "$LEVEL_HOME/README.txt")" -eq 1 ]
    [ "$(grep -c '^\* Exercise code:' "$LEVEL_HOME/README.txt")" -eq 1 ]
    [ "$(grep -c '^\*\{40\}$' "$LEVEL_HOME/README.txt")" -ge 3 ]
done
echo 'PolyBandit contract and syntax checks passed.'
