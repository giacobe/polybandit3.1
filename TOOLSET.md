# PolyBandit toolset

## Learner-facing commands

`base64`, `bzip2`, `cat`, `cd`, `file`, `find`, `grep`, `gzip`, `ls`, `mv`, `sort`, `strings`, `tar`, `tr`, `uniq`, `wc`, and `xxd`.

## Installer and generator commands

The learner commands plus `adduser`, `awk`, `chmod`, `chown`, `cp`, `cut`, `date`, `head`, `id`, `mkdir`, `passwd`, `printf`, `rm`, `sed`, `sha256sum`, `su`, and `touch`. The development-only test suite also uses `cmp`.

The validated `basic+compression` Buildroot feature set contains these commands.

## Static generator fixtures

`assets/binary-noise-1024.b64` is decoded once into fixed-size binary source files. `assets/text-records.txt` supplies invariant non-answer records for Bandits 8 and 9. The fixtures contain no participant answers or seed inputs.
