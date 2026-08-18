#!/usr/bin/env bash
# import-pgp-keys.sh
#


set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Keyservers to try, in order, for each key.
KEYSERVERS=(
  "hkps://keyserver.ubuntu.com"
  "hkps://keys.openpgp.org"
)

import_key() {
  local key="$1"
  local ks

  for ks in "${KEYSERVERS[@]}"; do
    echo "    trying $ks ..."
    if gpg --keyserver "$ks" --recv-keys "$key" 2>/dev/null; then
      echo "    imported $key from $ks"
      return 0
    fi
  done

  echo "    FAILED to import $key from any keyserver" >&2
  return 1
}

FAILED_KEYS=()

for dir in "$ROOT"/*/; do
  pkg="$(basename "$dir")"
  pkgbuild="$dir/PKGBUILD"

  [[ -f "$pkgbuild" ]] || continue

  keys="$(
    bash -c "source \"$pkgbuild\" 2>/dev/null; printf '%s\n' \"\${validpgpkeys[@]:-}\""
  )"

  # Skip if the array was empty/unset.
  if [[ -z "${keys// /}" ]]; then
    continue
  fi

  echo "==> $pkg: found $(wc -l <<< "$keys") key(s) to import"

  while IFS= read -r key; do
    [[ -n "$key" ]] || continue
    echo "  -> $key"
    import_key "$key" || FAILED_KEYS+=("$key")
  done <<< "$keys"
done

if [[ ${#FAILED_KEYS[@]} -gt 0 ]]; then
  echo "==> ERROR: failed to import ${#FAILED_KEYS[@]} key(s): ${FAILED_KEYS[*]}" >&2
  exit 1
fi

echo "==> All required PGP keys imported successfully."
