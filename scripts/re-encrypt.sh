#!/usr/bin/env bash
# Re-encrypt the Kestrel-OS site after editing the plaintext source.
#
# The public site (index.html) is encrypted with StatiCrypt. The plaintext
# source lives at index.src.html (gitignored). After editing the source,
# run this script to regenerate the encrypted index.html.
#
# Usage:
#   ./scripts/re-encrypt.sh
#     -> prompts for passphrase (does not echo)
#
#   STATICRYPT_PASSWORD='<passphrase>' ./scripts/re-encrypt.sh
#     -> uses env var (never touches shell history if set inline: env VAR=... cmd)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

if [ ! -f index.src.html ]; then
  echo "ERROR: index.src.html not found in $REPO_ROOT" >&2
  echo "This is the plaintext source. Restore your local copy before re-encrypting." >&2
  exit 1
fi

if [ -z "${STATICRYPT_PASSWORD:-}" ]; then
  read -rsp "Passphrase: " STATICRYPT_PASSWORD
  echo
  export STATICRYPT_PASSWORD
fi

OUT_DIR="$(mktemp -d)"
trap 'rm -rf "$OUT_DIR"' EXIT

npx --yes staticrypt index.src.html \
  -d "$OUT_DIR" \
  --short \
  --template-color-primary '#BD4257' \
  --template-color-secondary '#163C4D' \
  --template-instructions 'Enter the passphrase to view the Kestrel OS architecture documentation.' \
  >/dev/null

cp "$OUT_DIR/index.src.html" index.html

echo "index.html re-encrypted."
echo
echo "Next steps:"
echo "  git add index.html"
echo "  git commit -m 'Update Kestrel-OS content'"
echo "  git push"
