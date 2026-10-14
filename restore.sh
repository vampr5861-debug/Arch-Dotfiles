#!/usr/bin/env bash
set -euo pipefail
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
[[ $# -eq 1 ]] || die 'Usage: bash restore.sh "/path/to/Arch-Momo-backup-..."'
[[ $EUID -ne 0 ]] || die 'Do not run as root/sudo'
BACKUP=$(realpath -e -- "$1") || die 'Backup not found'
[[ -d $BACKUP && -f $BACKUP/manifest.tsv && -f $BACKUP/format ]] || die 'Not a supported backup'
[[ $(cat "$BACKUP/format") = momo-dotfiles-v1 ]] || die 'Unsupported backup format'
TARGET=${XDG_CONFIG_HOME:-$HOME/.config}
[[ $TARGET = /* && ! -L $TARGET && ( ! -e $TARGET || -d $TARGET ) ]] || die 'Unsafe configuration directory'
safe_path() {
  local parent
  parent=$(dirname -- "$1")
  while [[ $parent != "$TARGET" && $parent != / ]]; do
    [[ ! -L $parent && ( ! -e $parent || -d $parent ) ]] || die "Unsafe parent: $parent"
    parent=$(dirname -- "$parent")
  done
  [[ $parent = "$TARGET" ]] || die "Path escaped config directory: $1"
}
mkdir -p "$HOME/.cache"
exec 9>"$HOME/.cache/arch-momo-dotfiles.lock"
flock -n 9 || die 'Another install/restore is in progress'
while IFS=$'\t' read -r rel kind digest; do
  [[ $rel && $rel != /* && $rel != *..* && $digest =~ ^[a-f0-9]{64}$ ]] || die 'Invalid backup manifest'
  [[ $kind = file || $kind = symlink || $kind = absent ]] || die 'Invalid backup type'
  dest="$TARGET/$rel"
  safe_path "$dest"
  [[ -f $dest && ! -L $dest ]] || die "Destination changed/absent: $dest"
  actual=$(sha256sum "$dest")
  [[ ${actual%% *} = "$digest" ]] || die "Local changes detected; refusing to overwrite: $dest"
  if [[ $kind != absent ]]; then
    [[ -f "$BACKUP/original/$rel" || -L "$BACKUP/original/$rel" ]] || die "Original missing: $rel"
  fi
done < "$BACKUP/manifest.tsv"
printf 'Ready to restore backed-up files from %s\n' "$BACKUP"
read -r -p 'Proceed? [y/N] ' answer
[[ $answer = y || $answer = Y ]] || exit 0
while IFS=$'\t' read -r rel kind digest; do
  dest="$TARGET/$rel"
  rm -f -- "$dest"
  if [[ $kind != absent ]]; then
    cp -a -- "$BACKUP/original/$rel" "$dest"
  fi
  printf 'RESTORED %s (%s)\n' "$rel" "$kind"
done < "$BACKUP/manifest.tsv"
echo 'Restore completed.'
