# Arch Momo Noctalia — 2026-10-14

**Main desktop:** Hyprland (Lua, >= 0.55)  
**Backup desktop:** KDE Plasma (kept separate, unchanged).  
**Status:** statically checked, NOT runtime-tested on your computer.

## What's included

- `.config/hypr/hyprland.lua` — compact implementation of the old keybinds, split layout, 6 persistent workspaces, bilingual US/RU, subtle animation, audio and screenshots.
- `.config/rofi/config.rasi` — centered dark launcher, fuzzy search, 10 rows, drun/run/window; no extra rofi-calc plugin.
- `.config/kitty/kitty.conf` — matte terminal, safer opacity, no forced Fish shell.
- `.config/fish/config.fish` — Starship only in interactive sessions if installed.
- `.config/fastfetch/config.jsonc` — cleaned modern Fastfetch, removed the old questionable disk-as-OS-age module.
- `.config/noctalia/config.toml` — original user-supplied gray Noctalia v5 configuration (TOML), launched only in Hyprland. Validate with `noctalia config validate` after applying.
- `references/` — originals for comparison, **not** copied by installer. Noctalia is the main panel; reference is retained as well.
- `packages.txt` — list for review; it is not a blindly executed installer.

## Install / verify on Arch

1. Ensure your important data are stored **outside the SSD before wiping Windows or Arch**. This bundle contains configurations only, not your personal backup.
2. In a working KDE Plasma session, install dependencies if you need them (review `packages.txt`). The bundle does **not** install packages, drivers, SDDM, services or alter the disk. Install Noctalia on Arch using `sudo pacman -S noctalia` (v5+) before enabling the Hyprland session.
3. Extract this bundle, run `bash ./install.sh` to show a dry run.
4. If the target paths and contents look correct: `bash ./install.sh --apply` **without sudo**. Existing target files are copied to `~/Arch-Momo-backup-DATE` before replacement.
5. Log out from KDE; select **Hyprland** in SDDM. If an error occurs, choose **Plasma** on the next login.
6. In Hyprland run `hyprctl configerrors`, `hyprctl monitors`, and `noctalia config validate`; test panel, audio, clipboard, lockscreen, screenshot, GPU before doing more tweaks.
7. KDE remains its own desktop; do not reuse Hyprland-specific systemd user services as global startup items.

## Things that must be checked on the real machine

- Your actual display connector (`hyprctl monitors`); 6 persistent workspaces currently target `DP-1`. The monitor mode uses `preferred`, not a forced unsupported refresh. For 180 Hz, check availableModes first and uncomment monitor override.
- NVIDIA 3050 and hardware-accelerated apps; conservative `direct_scanout=0` on initial boot. Increase after testing if necessary.
- `XCURSOR_THEME=Adwaita` on purpose until custom Notwaita Black cursor installed.
- Installed versions of Hyprland, Kitty, Rofi and Noctalia. Static checks are not a substitute for actual application/runtime checks.
- Noctalia startup (`hl.on`), lockscreen (`hyprlock`), screenshot (`grim`,`slurp`), volume (`wpctl`) and playback (`playerctl`) require their packages.
- Rofi is installed from `extra/rofi` (current 2.0 packages have Wayland support). Rofi-calc is intentionally not referenced.
- Standalone Notwaita-Black, Firefox Cascade and other user assets were **not uploaded**; cannot safely reconstruct their exact appearance.
- Fastfetch displays host/memory/graphics; removing old questionable OS-age representation avoids making up installation age.

## Validate / rollback

- `bash -n install.sh restore.sh`
- `python -m json.tool .config/fastfetch/config.jsonc`
- `python -c "import tomllib;tomllib.load(open('.config/noctalia/config.toml','rb'))"`
- `hyprctl configerrors` **on your actual desktop**
- `rofi -config .config/rofi/config.rasi -show drun` (preview before switching)
- Backup directory is printed by installer; `./restore.sh "$HOME/Arch-Momo-backup-YYYYMMDD-HHMMSS"` restores files that had backups.
- `restore.sh` intentionally does not delete newly introduced files; remove the extra files manually if you want a complete rollback.

## Keystrokes

- Super+Enter = Kitty; Super+E = Thunar; Super+B = Firefox; Super+Space = Rofi drun
- Super+R = Rofi run; Super+Shift+Space = window picker; Super+Q = close; Super+V = floating
- Super+1..6 = workspaces; Super+Shift+1..6 = move window; Super+Arrows = focus
- Super+Ctrl+Arrows = resize; Super+Shift+Arrows = move; Super+Alt+Arrows = swap
- Super+L = lock; Super+Shift+S = region screenshot; Print = full screenshot

## Important boundaries

This bundle does NOT install the NVIDIA driver, edit GRUB, alter partitions, remove Windows, configure Snapper or overwrite Plasma. Both desktop sessions remain independent. **Do not wipe the drive until a separate verified backup is stored elsewhere.**

## Noctalia instead of Waybar

- No Waybar files or Waybar startup commands are present in this revised bundle.
- The uploaded Noctalia TOML uses `custom_palette = "MomoGray"`. Its referenced palette may need to be configured separately if that palette is not installed; runtime configuration validation and visual inspection are required.
- Noctalia is started by **one** Hyprland event hook. Avoid enabling any second Noctalia autostart/service, otherwise duplicate panels may appear.
- Rofi remains on `Super+Space`. Noctalia uses `Super+S` (control center), `Super+,` (settings), `Super+C` (clipboard), `Super+Shift+B` (bar), `Super+Escape` (session).
- Noctalia may also persist GUI overrides in `~/.local/state/noctalia/settings.toml`. If your TOML appears to be ignored, inspect the overrides; do not blindly delete them.
