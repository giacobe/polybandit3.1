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
