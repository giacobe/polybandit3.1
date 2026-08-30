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
echo 'PolyBandit contract and syntax checks passed.'
