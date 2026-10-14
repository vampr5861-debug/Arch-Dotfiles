#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}"
FILES=(
  'hypr/hyprland.lua' 'rofi/config.rasi' 'kitty/kitty.conf'
  'fastfetch/config.jsonc' 'fish/config.fish' 'noctalia/config.toml'
)
if [[ "${1:-}" != '--apply' ]]; then
  echo 'DRY RUN. These files will be copied (existing files backed up):'
  for relative in "${FILES[@]}"; do printf '  %s -> %s\n' "$DIR/.config/$relative" "$TARGET/$relative"; done
  echo 'Run: ./install.sh --apply'
  exit 0
fi
if [[ "$EUID" -eq 0 ]]; then echo 'Do not run as root / with sudo' >&2; exit 1; fi
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/Arch-Momo-backup-$STAMP"
mkdir -p -- "$BACKUP" "$TARGET"
for relative in "${FILES[@]}"; do
  source="$DIR/.config/$relative"
  dest="$TARGET/$relative"
  mkdir -p -- "$(dirname -- "$dest")"
  if [[ -e "$dest" || -L "$dest" ]]; then
    mkdir -p -- "$(dirname -- "$BACKUP/$relative")"
    cp -a -- "$dest" "$BACKUP/$relative"
  fi
  install -m 644 -- "$source" "$dest"
  printf 'Installed %s\n' "$relative"
done
printf '\nBackup directory: %s\n' "$BACKUP"
echo 'Do not restart everything at once: log into KDE first, then select Hyprland in SDDM.'
echo 'After Hyprland login: hyprctl configerrors; hyprctl monitors'
