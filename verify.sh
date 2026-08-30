#!/bin/sh
set -eu
root=${1:-/}
failed=0
for n in 1 2 3 4 5 6 7 8 9 10 11 12 13; do
  [ -f "$root/home/bandit$n/README.txt" ] || { echo "bandit$n README missing" >&2; failed=1; }
done
[ ! -e "$root/var/lib/polybandit/answers" ] || { echo 'forbidden answer store exists' >&2; failed=1; }
[ "$failed" -eq 0 ]
echo 'PolyBandit structure contains no answer store.'