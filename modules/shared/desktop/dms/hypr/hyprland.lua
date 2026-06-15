-- Hyprland Lua Configuration for DMS
-- https://wiki.hypr.land/Configuring/

-- ====================
-- AUTOSTART
-- ====================
hl.on("hyprland.start", function()
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")
  hl.exec_cmd("systemctl --user start hyprland-session.target")
  hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
  hl.exec_cmd("fcitx5 -d")
  hl.exec_cmd("dms run")
end)

-- ====================
-- ENVIRONMENT
-- ====================
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")

-- ====================
-- ANIMATIONS
-- ====================
-- speed is in deciseconds (1 ds = 100ms)
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 1, bezier = "default", style = "popin" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1, bezier = "default", style = "popin" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "border",      enabled = true, speed = 2, bezier = "default" })

-- ====================
-- MONITOR CONFIG
-- ====================
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = "auto",
})

-- ====================
-- INPUT CONFIG
-- ====================
hl.config({
  input = {
    kb_layout = "us",
    numlock_by_default = true,
  },
})

-- ====================
-- LOOK AND FEEL
-- ====================
hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 5,
    border_size = 2,
    layout = "dwindle",
    resize_on_border = false,
  },

  decoration = {
    rounding = 12,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    shadow = {
      enabled = true,
      range = 30,
      render_power = 5,
      color = "rgba(00000070)",
    },
  },


})

-- ====================
-- LAYOUT CONFIGS
-- ====================
hl.config({
  dwindle = {
    preserve_split = true,
  },

  master = {
    mfact = 0.5,
  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
  },
})

-- ====================
-- COLORS (DMS theme)
-- ====================
local primary  = "rgb(ca9ee6)"
local outline  = "rgb(737994)"
local error    = "rgb(e78284)"

hl.config({
  general = {
    col = {
      active_border = primary,
      inactive_border = outline,
    },
  },

  group = {
    col = {
      border_active = primary,
      border_inactive = outline,
      border_locked_active = error,
      border_locked_inactive = outline,
    },
    groupbar = {
      col = {
        active = primary,
        inactive = outline,
        locked_active = error,
        locked_inactive = outline,
      },
    },
  },
})

-- ====================
-- LAYOUT (DMS overrides)
-- ====================
hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 4,
    border_size = 2,
  },

  decoration = {
    rounding = 12,
  },
})

-- ====================
-- OUTPUTS (DMS monitor override)
-- ====================
hl.monitor({
  output = "",
  mode = "1920x1200@180",
  position = "0x0",
  scale = "1",
})

-- ====================
-- WINDOW RULES
-- ====================
hl.window_rule({
  name = "tile-wezterm",
  match = { class = "^org\\.wezfurlong\\.wezterm$" },
  tile = true,
})

hl.window_rule({
  name = "rounding-gnome",
  match = { class = "^org\\.gnome\\." },
  rounding = 12,
})

hl.window_rule({
  name = "tile-settings",
  match = { class = "^gnome-control-center$" },
  tile = true,
})

hl.window_rule({
  name = "tile-pavucontrol",
  match = { class = "^pavucontrol$" },
  tile = true,
})

hl.window_rule({
  name = "tile-nm",
  match = { class = "^nm-connection-editor$" },
  tile = true,
})

hl.window_rule({
  name = "float-calc-gnome",
  match = { class = "^org\\.gnome\\.Calculator$" },
  float = true,
})

hl.window_rule({
  name = "float-calc",
  match = { class = "^gnome-calculator$" },
  float = true,
})

hl.window_rule({
  name = "float-galculator",
  match = { class = "^galculator$" },
  float = true,
})

hl.window_rule({
  name = "float-blueman",
  match = { class = "^blueman-manager$" },
  float = true,
})

hl.window_rule({
  name = "float-nautilus",
  match = { class = "^org\\.gnome\\.Nautilus$" },
  float = true,
})

hl.window_rule({
  name = "float-xdg-portal",
  match = { class = "^xdg-desktop-portal$" },
  float = true,
})

hl.window_rule({
  name = "steam-toast",
  match = { class = "^steam$", title = "^notificationtoasts$" },
  no_initial_focus = true,
  pin = true,
})

hl.window_rule({
  name = "float-pip",
  match = { class = "^firefox$", title = "^Picture-in-Picture$" },
  float = true,
})

hl.window_rule({
  name = "float-zoom",
  match = { class = "^zoom$" },
  float = true,
})

-- ====================
-- KEYBINDS
-- ====================
local ipc = "dms ipc call "
local M = "SUPER"

-- Helper: exec_dms runs a dms IPC command
local ipc = "dms ipc call "

-- [[ Application Launchers ]]
hl.bind(M .. "+" .. "T",      hl.dsp.exec_cmd("kitty"))
hl.bind(M .. "+" .. "E",      hl.dsp.exec_cmd("dolphin"))
hl.bind(M .. "+" .. "RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind(M .. "+" .. "SPACE",  hl.dsp.exec_cmd("dms ipc call spotlight toggle"))
hl.bind(M .. "+" .. "V",      hl.dsp.exec_cmd("dms ipc call clipboard toggle"))
hl.bind(M .. "+" .. "M",      hl.dsp.exec_cmd("dms ipc call processlist focusOrToggle"))
hl.bind(M .. "+" .. "COMMA",  hl.dsp.exec_cmd("dms ipc call settings focusOrToggle"))
hl.bind(M .. "+" .. "N",      hl.dsp.exec_cmd("dms ipc call notifications toggle"))
hl.bind(M .. "+SHIFT" .. "+" .. "N",     hl.dsp.exec_cmd("dms ipc call notepad toggle"))
hl.bind(M .. "+" .. "Y",      hl.dsp.exec_cmd("dms ipc call dankdash wallpaper"))
hl.bind(M .. "+" .. "TAB",    hl.dsp.exec_cmd("dms ipc call hypr toggleOverview"))
hl.bind(M .. "+" .. "X",      hl.dsp.exec_cmd("dms ipc call powermenu toggle"))

-- [[ Cheat sheet ]]
hl.bind(M .. "+SHIFT" .. "+" .. "Slash", hl.dsp.exec_cmd("dms ipc call keybinds toggle hyprland"))

-- [[ Security ]]
hl.bind(M .. "+ALT" .. "+" .. "L",      hl.dsp.exec_cmd("dms ipc call lock lock"))
hl.bind(M .. "+SHIFT" .. "+" .. "E",      hl.dsp.exit())
hl.bind("CTRL+ALT" .. "+" .. "Delete", hl.dsp.exec_cmd("dms ipc call processlist focusOrToggle"))

-- [[ Audio Controls ]]
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("dms ipc call audio increment 3"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("dms ipc call audio decrement 3"))
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("dms ipc call audio mute"))
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("dms ipc call audio micmute"))
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("dms ipc call mpris playPause"))
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("dms ipc call mpris playPause"))
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("dms ipc call mpris previous"))
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("dms ipc call mpris next"))
hl.bind("CTRL" .. "+" .. "XF86AudioRaiseVolume", hl.dsp.exec_cmd("dms ipc call mpris increment 3"))
hl.bind("CTRL" .. "+" .. "XF86AudioLowerVolume", hl.dsp.exec_cmd("dms ipc call mpris decrement 3"))

-- [[ Brightness Controls ]]
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("dms ipc call brightness increment 5"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("dms ipc call brightness decrement 5"))

-- [[ Window Management ]]
hl.bind(M .. "+" .. "Q", hl.dsp.window.close())
hl.bind(M .. "+" .. "F", hl.dsp.window.fullscreen({ mode = "fullscreen"}))
hl.bind(M .. "+SHIFT" .. "+" .. "F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "unset"}))
hl.bind(M .. "+SHIFT" .. "+" .. "T", hl.dsp.window.float())
hl.bind(M .. "+" .. "W", hl.dsp.group.toggle())
hl.bind(M .. "+SHIFT" .. "+" .. "W", hl.dsp.exec_cmd("dms ipc call window-rules toggle"))

-- [[ Focus Navigation — arrows + hjkl ]]
hl.bind(M .. "+" .. "LEFT",  hl.dsp.focus({ direction = "l"}))
hl.bind(M .. "+" .. "DOWN",  hl.dsp.focus({ direction = "d"}))
hl.bind(M .. "+" .. "UP",    hl.dsp.focus({ direction = "u"}))
hl.bind(M .. "+" .. "RIGHT", hl.dsp.focus({ direction = "r"}))
hl.bind(M .. "+" .. "H",     hl.dsp.focus({ direction = "l"}))
hl.bind(M .. "+" .. "J",     hl.dsp.focus({ direction = "d"}))
hl.bind(M .. "+" .. "K",     hl.dsp.focus({ direction = "u"}))
hl.bind(M .. "+" .. "L",     hl.dsp.focus({ direction = "r"}))

-- [[ Window Movement — arrows + hjkl ]]
hl.bind(M .. "+SHIFT" .. "+" .. "LEFT",  hl.dsp.window.move({ direction = "l"}))
hl.bind(M .. "+SHIFT" .. "+" .. "DOWN",  hl.dsp.window.move({ direction = "d"}))
hl.bind(M .. "+SHIFT" .. "+" .. "UP",    hl.dsp.window.move({ direction = "u"}))
hl.bind(M .. "+SHIFT" .. "+" .. "RIGHT", hl.dsp.window.move({ direction = "r"}))
hl.bind(M .. "+SHIFT" .. "+" .. "H",     hl.dsp.window.move({ direction = "l"}))
hl.bind(M .. "+SHIFT" .. "+" .. "J",     hl.dsp.window.move({ direction = "d"}))
hl.bind(M .. "+SHIFT" .. "+" .. "K",     hl.dsp.window.move({ direction = "u"}))
hl.bind(M .. "+SHIFT" .. "+" .. "L",     hl.dsp.window.move({ direction = "r"}))

-- [[ Column Navigation ]]
hl.bind(M .. "+" .. "HOME", hl.dsp.focus({ window = "first"}))
hl.bind(M .. "+" .. "END",  hl.dsp.focus({ last = true }))

-- [[ Monitor Navigation ]]
hl.bind(M .. "+CTRL" .. "+" .. "LEFT",  hl.dsp.focus({ monitor = "l"}))
hl.bind(M .. "+CTRL" .. "+" .. "RIGHT", hl.dsp.focus({ monitor = "r"}))
hl.bind(M .. "+CTRL" .. "+" .. "H",     hl.dsp.focus({ monitor = "l"}))
hl.bind(M .. "+CTRL" .. "+" .. "J",     hl.dsp.focus({ monitor = "d"}))
hl.bind(M .. "+CTRL" .. "+" .. "K",     hl.dsp.focus({ monitor = "u"}))
hl.bind(M .. "+CTRL" .. "+" .. "L",     hl.dsp.focus({ monitor = "r"}))

-- [[ Move to Monitor ]]
hl.bind(M .. "+SHIFT+CTRL" .. "+" .. "LEFT",  hl.dsp.window.move({ monitor = "l"}))
hl.bind(M .. "+SHIFT+CTRL" .. "+" .. "DOWN",  hl.dsp.window.move({ monitor = "d"}))
hl.bind(M .. "+SHIFT+CTRL" .. "+" .. "UP",    hl.dsp.window.move({ monitor = "u"}))
hl.bind(M .. "+SHIFT+CTRL" .. "+" .. "RIGHT", hl.dsp.window.move({ monitor = "r"}))
hl.bind(M .. "+SHIFT+CTRL" .. "+" .. "H",     hl.dsp.window.move({ monitor = "l"}))
hl.bind(M .. "+SHIFT+CTRL" .. "+" .. "J",     hl.dsp.window.move({ monitor = "d"}))
hl.bind(M .. "+SHIFT+CTRL" .. "+" .. "K",     hl.dsp.window.move({ monitor = "u"}))
hl.bind(M .. "+SHIFT+CTRL" .. "+" .. "L",     hl.dsp.window.move({ monitor = "r"}))

-- [[ Workspace Navigation ]]
hl.bind(M .. "+" .. "PAGE_DOWN", hl.dsp.focus({ workspace = "e+1"}))
hl.bind(M .. "+" .. "PAGE_UP",   hl.dsp.focus({ workspace = "e-1"}))
hl.bind(M .. "+" .. "U",         hl.dsp.focus({ workspace = "e+1"}))
hl.bind(M .. "+" .. "I",         hl.dsp.focus({ workspace = "e-1"}))
hl.bind(M .. "+CTRL" .. "+" .. "DOWN",      hl.dsp.window.move({ workspace = "e+1"}))
hl.bind(M .. "+CTRL" .. "+" .. "UP",        hl.dsp.window.move({ workspace = "e-1"}))
hl.bind(M .. "+CTRL" .. "+" .. "U",         hl.dsp.window.move({ workspace = "e+1"}))
hl.bind(M .. "+CTRL" .. "+" .. "I",         hl.dsp.window.move({ workspace = "e-1"}))

-- [[ Workspace rename ]]
hl.bind("CTRL+SHIFT" .. "+" .. "R", hl.dsp.exec_cmd("dms ipc call workspace-rename open"))

-- [[ Move to Workspace ]]
hl.bind(M .. "+SHIFT" .. "+" .. "PAGE_DOWN", hl.dsp.window.move({ workspace = "e+1"}))
hl.bind(M .. "+SHIFT" .. "+" .. "PAGE_UP",   hl.dsp.window.move({ workspace = "e-1"}))
hl.bind(M .. "+SHIFT" .. "+" .. "U",         hl.dsp.window.move({ workspace = "e+1"}))
hl.bind(M .. "+SHIFT" .. "+" .. "I",         hl.dsp.window.move({ workspace = "e-1"}))

-- [[ Mouse Wheel Navigation ]]
hl.bind(M .. "+" .. "mouse_down", hl.dsp.focus({ workspace = "e+1"}))
hl.bind(M .. "+" .. "mouse_up",   hl.dsp.focus({ workspace = "e-1"}))
hl.bind(M .. "+CTRL" .. "+" .. "mouse_down", hl.dsp.window.move({ workspace = "e+1"}))
hl.bind(M .. "+CTRL" .. "+" .. "mouse_up",   hl.dsp.window.move({ workspace = "e-1"}))

-- [[ Numbered Workspaces ]]
for i = 1, 9 do
  hl.bind(M .. "+" .. tostring(i), hl.dsp.focus({ workspace = tostring(i) }))
  hl.bind(M .. "+SHIFT" .. "+" .. tostring(i), hl.dsp.window.move({ workspace = tostring(i) }))
end

-- [[ Column Management ]]
hl.bind(M .. "+" .. "BRACKETLEFT",  hl.dsp.layout("preselect l"))
hl.bind(M .. "+" .. "BRACKETRIGHT", hl.dsp.layout("preselect r"))

-- [[ Sizing & Layout ]]
hl.bind(M .. "+" .. "R",      hl.dsp.layout("togglesplit"))
hl.bind(M .. "+CTRL" .. "+" .. "F",      hl.dsp.exec_cmd("hyprctl dispatch resizeactive exact 100% 100%"))

-- [[ Manual Sizing ]]
hl.bind(M .. "+" .. "MINUS",  hl.dsp.exec_cmd("hyprctl dispatch resizeactive -10% 0"))
hl.bind(M .. "+" .. "EQUAL",  hl.dsp.exec_cmd("hyprctl dispatch resizeactive 10% 0"))
hl.bind(M .. "+SHIFT" .. "+" .. "MINUS",  hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -10%"))
hl.bind(M .. "+SHIFT" .. "+" .. "EQUAL",  hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 10%"))

-- [[ Screenshots ]]
hl.bind("Print", hl.dsp.exec_cmd("dms screenshot"))
hl.bind("CTRL" .. "+" .. "Print", hl.dsp.exec_cmd("dms screenshot full"))
hl.bind("ALT" .. "+" .. "Print", hl.dsp.exec_cmd("dms screenshot window"))

-- [[ DPMS ]]
hl.bind(M .. "+SHIFT" .. "+" .. "P", hl.dsp.dpms())

