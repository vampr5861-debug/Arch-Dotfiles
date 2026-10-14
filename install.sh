#!/usr/bin/env bash
# Apply only user-level dotfiles. No sudo, pacman, bootloader or disk operations.
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "$0")" && pwd -P)
TARGET=${XDG_CONFIG_HOME:-$HOME/.config}
FILES=(
  hypr/hyprland.lua
  rofi/config.rasi
  kitty/kitty.conf
  fish/config.fish
  fastfetch/config.jsonc
  noctalia/config.toml
  starship.toml
)
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
[[ $EUID -ne 0 ]] || die "Run as your normal user, not sudo/root."
[[ $TARGET = /* ]] || die "XDG_CONFIG_HOME must be an absolute path."
[[ ! -L $TARGET ]] || die "Refusing a symlinked config directory: $TARGET"
[[ ! -e $TARGET || -d $TARGET ]] || die "Config path is not a directory: $TARGET"
# Also refuse intermediate symlink directories so a destination cannot escape ~/.config.
safe_path() {
  local path=$1 parent
  parent=$(dirname -- "$path")
  while [[ $parent != "$TARGET" && $parent != / ]]; do
    [[ ! -L $parent && ( ! -e $parent || -d $parent ) ]] ||
      die "Unsafe parent directory: $parent"
    parent=$(dirname -- "$parent")
  done
  [[ $parent = "$TARGET" ]] || die "Destination escaped config directory: $path"
}
for rel in "${FILES[@]}"; do
  src="$ROOT/.config/$rel"
  dst="$TARGET/$rel"
  [[ -f $src && ! -L $src ]] || die "Missing/unsafe source: $src"
  safe_path "$dst"
  [[ ! -d $dst && ( ! -e $dst || -f $dst || -L $dst ) ]] ||
    die "Destination is not a regular file or symlink: $dst"
done
if [[ ${1:-} != --apply ]]; then
  [[ $# -eq 0 ]] || die "Usage: bash install.sh [--apply]"
  printf 'DRY RUN: proposed destinations (nothing changed):\n'
  for rel in "${FILES[@]}"; do
    [[ -f $TARGET/$rel && ! -L $TARGET/$rel ]] && cmp -s -- "$ROOT/.config/$rel" "$TARGET/$rel" && state=identical || state=replace
    printf '  %-29s %s\n' "$rel" "$state"
  done
  echo 'Apply only after reviewing code and dependencies: bash install.sh --apply'
  exit 0
fi
[[ $# -eq 1 ]] || die "Usage: bash install.sh [--apply]"
mkdir -p -- "$HOME/.cache"
exec 9>"$HOME/.cache/arch-momo-dotfiles.lock"
flock -n 9 || die "Another install/restore is in progress"
mkdir -p -- "$TARGET"
BACKUP=$(mktemp -d "$HOME/Arch-Momo-backup-$(date +%Y%m%d-%H%M%S)-XXXXXXXX")
chmod 700 "$BACKUP"
mkdir -p "$BACKUP/original"
printf 'momo-dotfiles-v1\n' > "$BACKUP/format"
: > "$BACKUP/manifest.tsv"
count=0
for rel in "${FILES[@]}"; do
  src="$ROOT/.config/$rel"
  dst="$TARGET/$rel"
  safe_path "$dst"
  if [[ -f $dst && ! -L $dst ]] && cmp -s -- "$src" "$dst"; then
    printf 'UNCHANGED %s\n' "$rel"
    continue
  fi
  kind=absent
  if [[ -L $dst ]]; then kind=symlink
  elif [[ -f $dst ]]; then kind=file
  elif [[ -e $dst ]]; then die "Unsafe destination: $dst"
  fi
  if [[ $kind != absent ]]; then
    mkdir -p -- "$BACKUP/original/$(dirname -- "$rel")"
    cp -a -- "$dst" "$BACKUP/original/$rel"
  fi
  hash=$(sha256sum -- "$src")
  hash=${hash%% *}
  # Record BEFORE writing, so a partially interrupted installation stays recoverable.
  printf '%s\t%s\t%s\n' "$rel" "$kind" "$hash" >> "$BACKUP/manifest.tsv"
  mkdir -p -- "$(dirname -- "$dst")"
  rm -f -- "$dst"
  install -m 644 -- "$src" "$dst"
  printf 'INSTALLED %s\n' "$rel"
  count=$((count + 1))
done
printf '\nChanged: %s\nBackup directory: %s\n' "$count" "$BACKUP"
printf 'Restore (after checking for user edits): bash restore.sh "%s"\n' "$BACKUP"
