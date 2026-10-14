# Test safely on existing Arch Linux (Dual Boot)

This repository modifies **only user-level files** under `~/.config`. It does not install programs, NVIDIA drivers, services, SDDM, KDE Plasma, bootloaders or partitions. **Do not wipe Windows.**

1. Stay in your existing KDE Plasma session. Make a backup/snapshot of important data separately from this repository. If using VirtualBox, make a VM snapshot first.
2. Verify required programs manually. At minimum, inspect `packages.txt`; Hyprland/Noctalia requires real Wayland session and a matching supported version.
3. Download the branch under review with `git clone -b modernize-safe-configs-20261014 https://github.com/vampr5861-debug/Arch-Dotfiles.git` (private repositories require authentication).
4. In the cloned directory, inspect `install.sh` and run `bash -n install.sh restore.sh` and `bash install.sh`. The latter is a **dry run**.
5. Review every destination and source, then (only after confirming) run `bash install.sh --apply` **without sudo**. A unique `~/Arch-Momo-backup-…` folder contains a file manifest, original files and links.
6. Log out of Plasma and select Hyprland in SDDM if available. On real hardware: `hyprctl configerrors`, `hyprctl monitors`, `nvidia-smi`, `noctalia config validate`. Read warning messages, not only exit codes. Check unlocking, polkit, PipeWire, Bluetooth, XWayland, screenshot and portals.
7. If a problem occurs, log into KDE and run `bash restore.sh "/home/USER/Arch-Momo-backup-…"` substituting the **exact path printed at installation**. Restore aborts on later edits rather than replacing them silently. It restores pre-existing symlinks and deletes files absent prior to install.

**Limitations:** No Hyprland or Noctalia runtime tests have been performed on the intended RTX 3050 / LG 180Hz system. The MomoGray palette asset is missing from the original repository; do not assume its original colors are reproduced. Keep another usable session and do not use this as a replacement for a full backup.

**Noctalia:** Panel height stays 42 px. System monitors use Noctalia's own `sysmon` widgets, and GPU temperature may be unavailable in a virtual machine.

**Why not split Hyprland Lua now?** A single known entry file reduces the risk of unverified module import semantics. Consider modularizing after runtime validation.
