# PolyLinux PolyBandit

This repository modernizes the thirteen-level PolyBandit 3.1 command-line exercise while preserving its learner tasks and `bandit1` through `bandit13` accounts.

## Seed and exercise code

Email addresses are trimmed and lowercased. For level `N`:

```text
level_password = LEVEL_PASSWORD_ROOT + N
level_seed = SHA256(email + YYYY-MM-DD + SYSTEM_PASSWORD + level_password)
derived(label) = SHA256(level_seed + ":" + label)
```

The participant sees an exercise code instead of a date:

```text
YYYY-MM-DD -> YYYYMMDD decimal -> uppercase hexadecimal
2026-08-02 -> 20260802 -> 13527C2
```

## Development

Run deterministic generation and all reference solvers:

```sh
sh test.sh
```

Inside the Buildroot guest, root runs:

```sh
./install.sh
```

For automation:

```sh
USER_ID=student@example.edu CURRENT_DATE=2026-08-02 \
SYSTEM_PASSWORD=exercisePassword LEVEL_PASSWORD_ROOT=levelPassword \
./install.sh --non-interactive --no-login
```

Expected answers are kept under `/var/lib/polybandit/answers` for development verification. Participants submit all thirteen answers through the external grader; no local `checklevel` command is installed.

## Build performance and readiness

Static fixture assets under `assets/` provide non-answer binary noise and text corpora for Bandits 5, 6, 8, 9, and 10. The installer decodes a temporary fixture cache once rather than fabricating hundreds of small records through separate hash processes.

The installer creates all thirteen accounts first, then builds levels through a bounded queue. `MAX_PARALLEL` defaults to `3` and accepts values from `1` through `4`. Each generator writes to `/home/.polybandit-build-banditN`; the completed home is atomically renamed to `/home/banditN` before `/var/run/polybandit/ready/banditN` is created. Failures create matching markers under `/var/run/polybandit/failed` and details are written to `/var/log/polybandit-build.log`.

Interactive installation waits only for `bandit1`. Later levels continue preparing after the first learner shell opens. Noninteractive `--no-login` installation waits for the full queue so automated verification sees a complete exercise.

## Build the browser VM

PolyBandit uses the `basic-compression` configuration from
[`giacobe/buildroot-builder2`](https://github.com/giacobe/buildroot-builder2),
validated with Buildroot `2025.02.15`. Its exercise data intentionally remains
close to OverTheWire Bandit and is excluded from themed-data modernization.

```sh
git clone https://github.com/giacobe/buildroot-builder2.git
cd buildroot-builder2
BUILDROOT_VERSION=2025.02.15 scripts/01-setup-buildroot.sh
scripts/02-build-baseline.sh --config basic-compression
scripts/03-package-payload.sh \
  --repo https://github.com/giacobe/polybandit3.1.git \
  --ref main \
  --baseline artifacts/basic-compression-<timestamp> \
  --output artifacts/polybandit3.1 \
  --output-prefix polybandit3.1
```

Replace `<timestamp>` with the stage-2 artifact directory. Review the manifest
and boot-test the exact generated image pair in v86 before publishing.
