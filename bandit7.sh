#!/bin/sh
set -eu
. "$INSTALL_ROOT/resources.sh"
answer=$(answer_token 20)
mkdir -p "$LEVEL_HOME/inhere" "$SYSTEM_EVIDENCE_ROOT"
target="$SYSTEM_EVIDENCE_ROOT/$levelToBuild.password"
printf '%s\n' "$answer" > "$target"
if [ "${SKIP_OWNERSHIP:-0}" -eq 0 ]; then chown "$levelToBuild:bandit6" "$target"; chmod 640 "$target"; fi
write_readme "The answer is somewhere on this computer in a regular file that is exactly 21 bytes. Its owner is bandit7 and its group is bandit6. Use find and suppress irrelevant permission errors.
Answer format: exactly 20 Base64url characters. Case matters; do not add spaces."
record_answer "$answer"
finish_level
