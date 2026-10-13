-- MOMO / ARCH 2026 — clean Hyprland Lua configuration (Hyprland >= 0.55)
-- Independent of KDE Plasma: nothing here changes ~/.config/kde* or SDDM.
-- Verify live options with: hyprctl configerrors

local mod = "SUPER"
local terminal = "kitty"
local files = "thunar"
local browser = "firefox"

-- Safe fallback for any display. To force 180 Hz, first check `hyprctl monitors`.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
-- Uncomment ONLY after confirming DP-1 supports this mode:
-- hl.monitor({ output = "DP-1", mode = "2560x1440@180", position = "auto", scale = 1, vrr = 2 })

-- Default cursor exists without downloading third-party assets.
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "22")
-- Set QT_QPA_PLATFORMTHEME only after confirming qt6ct/KDE integration.
-- Do not force KDE session environment into Hyprland.

hl.config({
    general = {
        gaps_in = 7, gaps_out = 10, float_gaps = 10,
        border_size = 1,
        col = { active_border = "rgba(aeb4ba70)", inactive_border = "rgba(454a5038)" },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 12, rounding_power = 2,
        active_opacity = 1.0, inactive_opacity = 1.0,
        shadow = { enabled = true, range = 6, render_power = 3, color = 0xaa000000 },
        blur = { enabled = true, size = 5, passes = 2, vibrancy = 0.04 },
    },
    animations = { enabled = true, workspace_wraparound = true },
    input = {
        kb_layout = "us,ru", kb_options = "grp:alt_shift_toggle",
        resolve_binds_by_sym = false, numlock_by_default = true,
        repeat_rate = 35, repeat_delay = 300,
        follow_mouse = 1, sensitivity = -0.5,
        touchpad = { natural_scroll = false },
    },
    dwindle = { preserve_split = false, smart_resizing = true },
    -- Conservative on NVIDIA while testing. Can change to 2 after verification.
    render = { direct_scanout = 0 },
    misc = { force_default_wallpaper = 0, disable_hyprland_logo = true,
             disable_splash_rendering = true, vrr = 2 },
})

hl.curve("momoOut", { type = "bezier", points = { { 0.23, 1.0 }, { 0.32, 1.0 } } })
hl.curve("momoFast", { type = "bezier", points = { { 0.15, 0.0 }, { 0.10, 1.0 } } })
for _, name in ipairs({ "border", "windows", "fade", "layers" }) do
    hl.animation({ leaf = name, enabled = true, speed = 4, bezier = "momoOut" })
end
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "momoOut", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.5, bezier = "momoFast", style = "popin 94%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3.3, bezier = "momoOut", style = "slidefade 18%" })

-- Noctalia is the only panel/shell; start it ONLY in Hyprland.
-- KDE Plasma and SDDM remain independent. Do not also enable a global Noctalia service.
hl.on("hyprland.start", function()
    hl.exec_cmd("noctalia")
end)

for i = 1, 6 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1", persistent = true, default = (i == 1) })
end
hl.workspace_rule({ workspace = "special:scratch", on_created_empty = terminal })

-- Applications / launchers
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + E", hl.dsp.exec_cmd(files))
hl.bind(mod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + Space", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mod .. " + R", hl.dsp.exec_cmd("rofi -show run"))
hl.bind(mod .. " + SHIFT + Space", hl.dsp.exec_cmd("rofi -show window"))

-- Noctalia panels. Keep Rofi as the main app launcher (Super+Space).
local noctaliaIpc = "noctalia msg "
hl.bind(mod .. " + S", hl.dsp.exec_cmd(noctaliaIpc .. "panel-toggle control-center"))
hl.bind(mod .. " + comma", hl.dsp.exec_cmd(noctaliaIpc .. "settings-toggle"))
hl.bind(mod .. " + C", hl.dsp.exec_cmd(noctaliaIpc .. "panel-toggle clipboard"))
hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd(noctaliaIpc .. "bar-toggle"))
hl.bind(mod .. " + Escape", hl.dsp.exec_cmd(noctaliaIpc .. "panel-toggle session"))

-- Windows
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mod .. " + P", hl.dsp.window.pseudo({ action = "toggle" }))
hl.bind(mod .. " + SHIFT + P", hl.dsp.window.pin({ action = "toggle" }))
hl.bind(mod .. " + ALT + C", hl.dsp.window.center({}))
hl.bind(mod .. " + Tab", hl.dsp.window.cycle_next({ next = true }))
hl.bind("ALT + Tab", hl.dsp.window.cycle_next({ next = true }))
hl.bind(mod .. " + SHIFT + T", hl.dsp.layout("swapsplit"))
hl.bind(mod .. " + bracketleft", hl.dsp.layout("splitratio -0.1"))
hl.bind(mod .. " + bracketright", hl.dsp.layout("splitratio +0.1"))

for _, spec in ipairs({
    { "left", "left", -40, 0 }, { "right", "right", 40, 0 },
    { "up", "up", 0, -40 }, { "down", "down", 0, 40 },
}) do
    local key, dir, x, y = spec[1], spec[2], spec[3], spec[4]
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = dir }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
    hl.bind(mod .. " + ALT + " .. key, hl.dsp.window.swap({ direction = dir }))
    hl.bind(mod .. " + CTRL + " .. key,
        hl.dsp.window.resize({ x = x, y = y, relative = true }), { repeating = true })
end

-- Six workspaces, with keyboard and scroll wheel access.
for i = 1, 6 do
    local key = tostring(i)
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mod .. " + grave", hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:scratch", follow = false }))
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media, audio, screenshot, screen lock (separate lightweight utilities).
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind(mod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("sh -c 'mkdir -p \"$HOME/Pictures\"; grim -g \"$(slurp)\" \"$HOME/Pictures/Screenshot-$(date +%Y%m%d-%H%M%S).png\"'"))
hl.bind("Print", hl.dsp.exec_cmd("sh -c 'mkdir -p \"$HOME/Pictures\"; grim \"$HOME/Pictures/Screenshot-$(date +%Y%m%d-%H%M%S).png\"'"))

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Clean PiP; avoid broad window rules that grab dialogs in the wrong place.
hl.window_rule({
    name = "firefox-pip", match = { class = "firefox", title = "^(Picture-in-Picture|Picture in picture)$" },
    float = true, pin = true, keep_aspect_ratio = true,
})


-- Blur for Noctalia surfaces (official Noctalia Hyprland integration).
hl.layer_rule({
    name = "noctalia-shell",
    match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$" },
    no_anim = true, ignore_alpha = 0.5,
    blur = true, blur_popups = true,
})
