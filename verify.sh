#!/bin/sh
set -eu

ANSWER_DIR=${ANSWER_DIR:-/var/lib/polybandit/answers}
HOME_ROOT=${HOME_ROOT:-/home}
SYSTEM_EVIDENCE_ROOT=${SYSTEM_EVIDENCE_ROOT:-/var/lib/polybandit/evidence}
failures=0

check() {
    level=$1; actual=$2
    expected=$(sed -n '1p' "$ANSWER_DIR/bandit$level")
    if [ "$actual" = "$expected" ]; then
        echo "bandit$level: PASS"
    else
        echo "bandit$level: FAIL" >&2
        echo "  expected: $expected" >&2
        echo "  solver:   $actual" >&2
        failures=$((failures + 1))
    fi
}

check 1 "$(cat "$HOME_ROOT/bandit1/inhere.txt")"
check 2 "$(cat "$HOME_ROOT/bandit2/./-")"
check 3 "$(cat "$HOME_ROOT/bandit3/spaces in this filename")"
check 4 "$(cat "$HOME_ROOT/bandit4/inhere/.hidden")"

actual=''
for candidate in "$HOME_ROOT/bandit5/inhere"/*; do
    if file "$candidate" | grep -q 'text'; then actual=$(cat "$candidate"); fi
done
check 5 "$actual"

candidate=$(find "$HOME_ROOT/bandit6/inhere" -type f -size 205c ! -perm /111 | sed -n '1p')
actual=$(sed -n '1p' "$candidate")
check 6 "$actual"

if [ "${VERIFY_SKIP_OWNERSHIP:-0}" -eq 1 ]; then
    candidate=$(find "$SYSTEM_EVIDENCE_ROOT" -type f -size 21c | sed -n '1p')
else
    candidate=$(find / -type f -user bandit7 -group bandit6 -size 21c 2>/dev/null | sed -n '1p')
fi
check 7 "$(cat "$candidate")"

check 8 "$(grep 'millionth' "$HOME_ROOT/bandit8/data.txt" | awk '{print $2}')"
check 9 "$(sort "$HOME_ROOT/bandit9/data.txt" | uniq -u)"
check 10 "$(strings "$HOME_ROOT/bandit10/data.txt" | sed -n 's/^====== //p' | tail -n 1)"
check 11 "$(base64 -d "$HOME_ROOT/bandit11/data.txt" | awk '{print $NF}')"
check 12 "$(tr 'A-Za-z' 'N-ZA-Mn-za-m' < "$HOME_ROOT/bandit12/data.txt" | awk '{print $NF}')"

work="${TMPDIR:-/tmp}/polybandit-verify-13"
rm -rf "$work"; mkdir -p "$work"; cd "$work"
xxd -r "$HOME_ROOT/bandit13/data.txt" > data2.bin
mv data2.bin data2.gz; gzip -d data2.gz
mv data2 data3.bz2; bzip2 -d data3.bz2
mv data3 data4.gz; gzip -d data4.gz
mv data4 data5.tar; tar -xf data5.tar
tar -xf data5.bin
mv data6.bin data7.bz2; bzip2 -d data7.bz2
mv data7 data8.tar; tar -xf data8.tar
mv data8.bin data9.gz; gzip -d data9.gz
actual=$(awk '{print $NF}' data9)
cd /; rm -rf "$work"
check 13 "$actual"

if [ "$failures" -ne 0 ]; then echo "$failures level(s) failed validation." >&2; exit 1; fi
echo "All 13 PolyBandit levels passed."
