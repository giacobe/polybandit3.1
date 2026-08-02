# PolyBandit level contract

Every level produces one exact, case-sensitive, 20-character Base64url answer. The answer is the first 20 characters of the Base64url encoding of the 64 ASCII hexadecimal characters in `SHA256(level_seed + ":answer")`.

| Level | Primary skill | Evidence and invariant |
|---:|---|---|
| 1 | Read a file | `inhere.txt` contains the answer. |
| 2 | Dash-prefixed filename | A file named `-` must be addressed as a pathname. |
| 3 | Quoting | A filename contains spaces. |
| 4 | Hidden entries | Exactly one hidden answer file exists under `inhere`. |
| 5 | `file` classification | Exactly one candidate is human-readable text. |
| 6 | Recursive metadata search | Exactly one regular file is readable text, 205 bytes, and non-executable. |
| 7 | System-wide `find` | Exactly one 21-byte file is owned by `bandit7:bandit6`. |
| 8 | Contextual text search | The answer follows the unique word `millionth`. |
| 9 | Sorting and uniqueness | The answer is the only line occurring once. |
| 10 | Printable strings | The answer is the printable string preceded by `====== `. |
| 11 | Base64 decoding | Decoded text ends with the answer. |
| 12 | ROT13 | Decoded text ends with the answer. |
| 13 | Hexdump and compression | Reversing the deterministic archive chain yields text ending with the answer. |

All distractors are derived independently with labeled hashes. Correct evidence is selected before noise, and generators construct uniqueness rather than relying on chance.
