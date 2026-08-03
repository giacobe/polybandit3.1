---
title: "PolyBandit: Linux Command-Line Practice"
short_title: "PolyBandit"
panel_title: "Learning Path"
form_url: ""

---

# PolyBandit: Linux Command-Line Practice

PolyBandit contains thirteen short investigations that build confidence with Linux files, paths, searches, text processing, encodings, and archives.

## Start the exercise

The VM starts as root and asks for your email address. Leading and trailing spaces are removed, and the address is converted to lowercase. Confirm the displayed address carefully because it determines your exercise.

After the files are built, you enter `bandit1`. Read the level instructions with:

```sh
cat README.txt
```

Each README prominently displays an exercise code. Save that code and make sure it matches the code entered with your final submission.

## Move between levels

```sh
nextlevel
prevlevel
```

Navigation is not gated. You may revisit any generated level without solving the previous one.

Levels are prepared concurrently after you confirm your email address. `bandit1` is complete before your first learner shell opens. If you move faster than a later level is prepared, `nextlevel` or `prevlevel` will ask you to wait briefly and try again. A level is never opened with partially generated evidence.

## Answer rules

Every answer contains exactly 20 Base64url characters. Answers are case-sensitive. Copy the answer without surrounding spaces or explanatory words. Submit all thirteen answers together through the external answer form.

## Command reference

| Command | Purpose |
|---|---|
| `ls` | List directory entries; `ls -la` includes hidden entries. |
| `cat` | Display a file. |
| `file` | Classify file contents. |
| `find` | Search recursively by type, size, permissions, owner, or group. |
| `grep` | Select lines containing a pattern. |
| `sort` | Place lines in lexical order. |
| `uniq` | Count or select adjacent duplicate lines after sorting. |
| `strings` | Extract printable text from binary data. |
| `base64` | Encode or decode Base64 data. |
| `tr` | Translate characters, including ROT13. |
| `xxd` | Create or reverse a hexadecimal dump. |
| `gzip`, `bzip2` | Compress or decompress data. |
| `tar` | Create or extract archives. |

## Progressive hints

### Bandit 1

Start with `ls`, then display the named file.

### Bandit 2

A bare `-` often means standard input. Add a pathname component such as `./`.

### Bandit 3

Use quotes or escape each space in the filename.

### Bandit 4

Use an option that includes dot-prefixed entries.

### Bandit 5

Run `file` against every candidate and look for text rather than binary data.

### Bandit 6

Combine `find` predicates for regular files, exact byte size, and executable bits. Confirm the surviving file with `file`.

### Bandit 7

Search from `/` with owner, group, type, and exact-size predicates. Redirect permission errors away from the terminal.

### Bandit 8

Search `data.txt` for the distinctive word and inspect the field beside it.

### Bandit 9

`uniq` only recognizes adjacent duplicates, so sort first.

### Bandit 10

Extract printable strings, then select the line marked with repeated equals signs.

### Bandit 11

Decode the file rather than encoding it again.

### Bandit 12

ROT13 maps `A-Z` and `a-z` onto their thirteen-position rotations.

### Bandit 13

Work in a temporary directory. Reverse the hex dump first, then use `file` after every extraction or decompression step. Extensions are only hints; detected content is authoritative.

## Troubleshooting

If an answer is rejected, verify its case and remove surrounding spaces. Confirm that the submitted email matches the normalized address shown in the VM and that the exercise code matches the README. Reloading the VM rebuilds the exercise, so save answers outside the VM before reloading.

If a navigation command says that the destination is still being prepared, wait a moment and run the command again. If it reports that preparation failed, restart the VM; a persistent failure should be reported to the lab administrator.
