#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 1 ]]; then echo 'Usage: ./restore.sh "$HOME/Arch-Momo-backup-YYYYMMDD-HHMMSS"' >&2; exit 2; fi
BACKUP="$(realpath -- "$1")"
[[ -d "$BACKUP" ]] || { echo 'Backup not found' >&2; exit 1; }
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}"
read -r -p "Restore saved files into $TARGET? [y/N] " confirm
[[ "$confirm" == 'y' || "$confirm" == 'Y' ]] || exit 0
while IFS= read -r -d '' src; do
  rel="${src#$BACKUP/}"
  dest="$TARGET/$rel"
  mkdir -p -- "$(dirname -- "$dest")"
  cp -a -- "$src" "$dest"
  echo "Restored $rel"
done < <(find "$BACKUP" -type f -print0)
echo 'Previously absent files are NOT deleted automatically; see README.'
