# Audit of supplied dotfiles — 2026-10-14

## Inventory and source choices

The user uploaded 16 historical Hyprland Lua variants, 12 Rofi RASI variants, 11 Fastfetch JSONC variants, two Noctalia TOML files, Kitty, Fish and minor KDE session-state files. (The raw upload set includes duplicates and differently named snapshots.)

Primary references were `hyprland(2).lua` (most comprehensive recent variant), `config(1).rasi` / `rofi-raycast-refined(2).rasi`, `config.jsonc` / `config.jsonc.FINAL`, `config.toml`, `kitty(3).conf`, and `config.fish`. Comparing Hyprland backups shows incremental changes such as changing `dolphin` to `thunar` and adjusting input, cursor, VRR, startup, but not a reproducible dependency manifest.

## Confirmed issues / changes

1. **Fish:** `starship init fish | source` was unconditional. New file only initializes in interactive sessions and if `starship` is available.
2. **Kitty:** old `shell /usr/bin/fish` forced Fish regardless of the account login shell; removed. Opacity `0.72` increased to `0.93` for readability. Blur delegated to compositor for fewer client-side assumptions.
3. **Rofi:** some variants explicitly included `calc`, requiring optional `rofi-calc`. New Rofi intentionally uses only `drun,run,window`; modes and theme are kept minimal, focused on 700px width and 10 rows.
4. **Fastfetch:** `config.jsonc.save` fails JSONC parsing; it is **not** selected. `config.jsonc.FINAL` includes extra visual section headings; clean current version is used. The questionable disk `{days}` OS-age block from `config.jsonc` is removed because it cannot be verified as actual OS installation age.
5. **Hyprland:** archived config starts Noctalia unconditionally and hard-codes `QT_QPA_PLATFORMTHEME=kde`; revised version starts Noctalia **Hyprland-only**, and does not touch KDE environment. Keeps substantial keyboard controls, 6 workspaces, visual style, Russian/English layout, smooth animations and VRR.
6. **NVIDIA:** changed initial `render.direct_scanout` 2 -> 0 for safe first boot; re-enable only after driver/hardware tests. Avoided hard-coding unverified 180 Hz. Set system-provided Adwaita cursor as safe initial default.
7. **KDE:** the uploaded Dolphin tab/session state and KWin logout session are not full KDE configuration; neither is installed, to avoid restoring stale local paths or corrupting a fresh Plasma setup. SDDM is untouched.
8. **Noctalia:** supplied valid TOML syntax, but there is no evidence that its option names match a future installed Noctalia build. Original is installed to `.config/noctalia/config.toml` and Noctalia starts in Hyprland; runtime compatibility is still unverified.
9. **Installer:** no disk operations, no pacman/AUR actions and no sudo; dry-run by default and backups before overwriting.

## Static verification performed

- Lua source and generated file: syntax-compiled by liblua 5.4 (`luaL_loadbufferx`): **PASS**.
- Original & new Noctalia TOML: Python `tomllib` syntax validation: **PASS**.
- Generated Fastfetch JSONC: JSON parse validation: **PASS**.
- `install.sh` and `restore.sh`: `bash -n`: **PASS**.
- `install.sh` dry-run: **PASS**.
- Source backups contained identical duplicate files; no duplicate backup is auto-installed.
- References scanned for obvious `token/secret/password/https://` strings; no user secrets detected. This is a heuristic scan, **not a cryptographic guarantee**.

## Cannot be asserted without running on your hardware

- Hyprland API option validation (`hyprctl configerrors`) and compositor startup.
- Kitty/Rofi/Noctalia runtime theme validation, full keyboard shortcut semantics and font rendering.
- NVIDIA graphics stability/VRR/180 Hz on specific monitor, PipeWire and Bluetooth connections.
- Missing assets (Notwaita-Black cursor theme, Firefox Cascade CSS, complete KDE settings, original wallpaper/image assets).
- Disk operations or preservation of Windows: the bundle does not touch the disk, bootloader or partitions.

## Verification commands on Arch

```sh
hyprctl configerrors
hyprctl monitors
nvidia-smi
pacman -Q hyprland rofi kitty noctalia fish starship fastfetch
rofi -config ~/.config/rofi/config.rasi -show drun
```

For problems, log in with KDE Plasma using SDDM, and restore backed-up config files with the printed backup path.

## Revision — Noctalia preference

- User prefers Noctalia rather than Waybar; removed Waybar configuration, dependency, and startup.
- Installed uploaded `config.toml` as the Noctalia profile and added documented compositor-only autostart.
- Preserved Rofi as main launcher and added Noctalia IPC hotkeys and shell surface blur.
- Noctalia TOML is syntactically valid, **but** the referenced MomoGray palette and runtime option compatibility cannot be guaranteed by TOML parsing alone. Validate with `noctalia config validate`.
