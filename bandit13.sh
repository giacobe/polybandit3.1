#!/bin/sh
set -eu
. "$INSTALL_ROOT/resources.sh"
answer=$(answer_token 20)
work="${TMPDIR:-/tmp}/polybandit-$levelToBuild"
case "$work" in */polybandit-bandit13) ;; *) die "unsafe work directory: $work" ;; esac
rm -rf "$work"; mkdir -p "$work"; cd "$work"
printf 'the answer for this level is %s\n' "$answer" > data9
touch -t 202401010000 data9
gzip -n data9; mv data9.gz data8.bin; touch -t 202401010000 data8.bin
tar -cf data8.tar data8.bin; rm data8.bin; mv data8.tar data7
bzip2 data7; mv data7.bz2 data6.bin
touch -t 202401010000 data6.bin
tar -cf data6.tar data6.bin; rm data6.bin; mv data6.tar data5.bin
touch -t 202401010000 data5.bin
tar -cf data5.tar data5.bin; rm data5.bin; mv data5.tar data4
gzip -n data4; mv data4.gz data3
bzip2 data3; mv data3.bz2 data2
gzip -n data2; mv data2.gz data2.bin
xxd data2.bin > "$LEVEL_HOME/data.txt"
cd /; rm -rf "$work"
write_readme "The answer is stored in data.txt, a hexdump of a file that has been repeatedly compressed and archived. Work in a temporary directory, reverse the hexdump, and use file after each step.
Answer format: exactly 20 Base64url characters. Case matters; submit only the final value after the words is."
finish_level
