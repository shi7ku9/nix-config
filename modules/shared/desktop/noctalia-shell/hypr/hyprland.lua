-- Hyprland Lua Configuration for noctalia-shell
-- https://wiki.hypr.land/Configuring/

-- ====================
-- AUTOSTART
-- ====================
hl.on("hyprland.start", function()
  exec("dbus-update-activation-environment --systemd --all")
  exec("systemctl --user start hyprland-session.target")
  exec("noctalia-shell")
end)

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

  animations = {
    enabled = true,
    leaves = {
      { name = "windowsIn",     speed = 1, curve = "default", style = "popin"  },
      { name = "windowsOut",    speed = 1, curve = "default", style = "popin"  },
      { name = "workspaces",    speed = 1, curve = "default"                   },
      { name = "windowsMove",   speed = 1, curve = "default"                   },
      { name = "fade",          speed = 1, curve = "default"                   },
      { name = "border",        speed = 1, curve = "default"                   },
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
local ipc = "noctalia-shell ipc call "
local M = "SUPER"

-- [[ Application Launchers ]]
hl.bind(M, "T",           "exec", "kitty")
hl.bind(M, "E",           "exec", "dolphin")
hl.bind(M, "RETURN",      "exec", "kitty")
hl.bind(M, "SPACE",       "exec", ipc .. "launcher toggle")
hl.bind(M, "V",           "exec", ipc .. "launcher clipboard")
hl.bind(M, "M",           "exec", ipc .. "sessionMenu toggle")
hl.bind(M, "COMMA",       "exec", ipc .. "settings toggle")
hl.bind(M, "N",           "exec", ipc .. "notifications toggleHistory")
hl.bind(M, "Y",           "exec", ipc .. "wallpaper toggle")
hl.bind(M, "TAB",         "exec", ipc .. "launcher windows")
hl.bind(M, "X",           "exec", ipc .. "sessionMenu toggle")

-- [[ Cheat sheet ]]
hl.bind(M .. "+SHIFT",  "Slash",    "exec", ipc .. "plugin:keybind-cheatsheet toggle")

-- [[ Security & Session ]]
hl.bind(M .. "+ALT",    "L",        "exec", ipc .. "lockScreen lock")
hl.bind(M .. "+SHIFT",  "E",        "exit", "")
hl.bind("CTRL+ALT",     "Delete",   "exec", "loginctl lock-session")

-- [[ Audio Controls ]]
hl.bind("",             "XF86AudioRaiseVolume", "exec", ipc .. "volume increase")
hl.bind("",             "XF86AudioLowerVolume", "exec", ipc .. "volume decrease")
hl.bind("",             "XF86AudioMute",        "exec", ipc .. "volume muteOutput")
hl.bind("",             "XF86AudioMicMute",     "exec", "amixer set Capture toggle")
hl.bind("",             "XF86AudioPause",       "exec", "playerctl play-pause")
hl.bind("",             "XF86AudioPlay",        "exec", "playerctl play-pause")
hl.bind("",             "XF86AudioPrev",        "exec", "playerctl previous")
hl.bind("",             "XF86AudioNext",        "exec", "playerctl next")
hl.bind("CTRL",         "XF86AudioRaiseVolume", "exec", "playerctl volume 0.05+")
hl.bind("CTRL",         "XF86AudioLowerVolume", "exec", "playerctl volume 0.05-")

-- [[ Brightness Controls ]]
hl.bind("",             "XF86MonBrightnessUp",   "exec", ipc .. "brightness increase")
hl.bind("",             "XF86MonBrightnessDown", "exec", ipc .. "brightness decrease")

-- [[ Window Management ]]
hl.bind(M, "Q",             "killactive", "")
hl.bind(M, "F",             "fullscreen", "1")
hl.bind(M .. "+SHIFT", "F", "fullscreen", "0")
hl.bind(M .. "+SHIFT", "T", "togglefloating", "")
hl.bind(M, "W",             "togglegroup", "")

-- [[ Focus Navigation — arrows + hjkl ]]
hl.bind(M, "LEFT",  "movefocus", "l")
hl.bind(M, "DOWN",  "movefocus", "d")
hl.bind(M, "UP",    "movefocus", "u")
hl.bind(M, "RIGHT", "movefocus", "r")
hl.bind(M, "H",     "movefocus", "l")
hl.bind(M, "J",     "movefocus", "d")
hl.bind(M, "K",     "movefocus", "u")
hl.bind(M, "L",     "movefocus", "r")

-- [[ Window Movement — arrows + hjkl ]]
hl.bind(M .. "+SHIFT", "LEFT",  "movewindow", "l")
hl.bind(M .. "+SHIFT", "DOWN",  "movewindow", "d")
hl.bind(M .. "+SHIFT", "UP",    "movewindow", "u")
hl.bind(M .. "+SHIFT", "RIGHT", "movewindow", "r")
hl.bind(M .. "+SHIFT", "H",     "movewindow", "l")
hl.bind(M .. "+SHIFT", "J",     "movewindow", "d")
hl.bind(M .. "+SHIFT", "K",     "movewindow", "u")
hl.bind(M .. "+SHIFT", "L",     "movewindow", "r")

-- [[ Column Navigation ]]
hl.bind(M, "HOME", "focuswindow", "first")
hl.bind(M, "END",  "focuswindow", "last")

-- [[ Monitor Navigation ]]
hl.bind(M .. "+CTRL", "LEFT",  "focusmonitor", "l")
hl.bind(M .. "+CTRL", "RIGHT", "focusmonitor", "r")
hl.bind(M .. "+CTRL", "H",     "focusmonitor", "l")
hl.bind(M .. "+CTRL", "J",     "focusmonitor", "d")
hl.bind(M .. "+CTRL", "K",     "focusmonitor", "u")
hl.bind(M .. "+CTRL", "L",     "focusmonitor", "r")

-- [[ Move to Monitor ]]
hl.bind(M .. "+SHIFT+CTRL", "LEFT",  "movewindow", "mon:l")
hl.bind(M .. "+SHIFT+CTRL", "DOWN",  "movewindow", "mon:d")
hl.bind(M .. "+SHIFT+CTRL", "UP",    "movewindow", "mon:u")
hl.bind(M .. "+SHIFT+CTRL", "RIGHT", "movewindow", "mon:r")
hl.bind(M .. "+SHIFT+CTRL", "H",     "movewindow", "mon:l")
hl.bind(M .. "+SHIFT+CTRL", "J",     "movewindow", "mon:d")
hl.bind(M .. "+SHIFT+CTRL", "K",     "movewindow", "mon:u")
hl.bind(M .. "+SHIFT+CTRL", "L",     "movewindow", "mon:r")

-- [[ Workspace Navigation ]]
hl.bind(M, "PAGE_DOWN",  "workspace",       "e+1")
hl.bind(M, "PAGE_UP",    "workspace",       "e-1")
hl.bind(M, "U",          "workspace",       "e+1")
hl.bind(M, "I",          "workspace",       "e-1")
hl.bind(M .. "+CTRL",    "DOWN",            "movetoworkspace", "e+1")
hl.bind(M .. "+CTRL",    "UP",              "movetoworkspace", "e-1")
hl.bind(M .. "+CTRL",    "U",               "movetoworkspace", "e+1")
hl.bind(M .. "+CTRL",    "I",               "movetoworkspace", "e-1")

-- [[ Move to Workspace ]]
hl.bind(M .. "+SHIFT", "PAGE_DOWN", "movetoworkspace", "e+1")
hl.bind(M .. "+SHIFT", "PAGE_UP",   "movetoworkspace", "e-1")
hl.bind(M .. "+SHIFT", "U",         "movetoworkspace", "e+1")
hl.bind(M .. "+SHIFT", "I",         "movetoworkspace", "e-1")

-- [[ Mouse Wheel Navigation ]]
hl.bind(M,              "mouse_down", "workspace",       "e+1")
hl.bind(M,              "mouse_up",   "workspace",       "e-1")
hl.bind(M .. "+CTRL",   "mouse_down", "movetoworkspace",  "e+1")
hl.bind(M .. "+CTRL",   "mouse_up",   "movetoworkspace",  "e-1")

-- [[ Numbered Workspaces ]]
for i = 1, 9 do
  hl.bind(M,              tostring(i), "workspace",      tostring(i))
  hl.bind(M .. "+SHIFT",  tostring(i), "movetoworkspace", tostring(i))
end

-- [[ Column Management ]]
hl.bind(M, "BRACKETLEFT",  "layoutmsg", "preselect l")
hl.bind(M, "BRACKETRIGHT", "layoutmsg", "preselect r")

-- [[ Sizing & Layout ]]
hl.bind(M, "R",             "layoutmsg", "togglesplit")
hl.bind(M .. "+CTRL", "F",  "resizeactive", "exact 100% 100%")

-- [[ Resize with keys ]]
hl.bind(M, "MINUS",  "resizeactive", "-10% 0")
hl.bind(M, "EQUAL",  "resizeactive", "10% 0")
hl.bind(M .. "+SHIFT", "MINUS", "resizeactive", "0 -10%")
hl.bind(M .. "+SHIFT", "EQUAL", "resizeactive", "0 10%")

-- [[ Mouse Move / Resize ]]
hl.bind_mouse(M, "mouse:272", "movewindow")
hl.bind_mouse(M, "mouse:273", "resizewindow")

-- [[ Screenshots ]]
hl.bind("",    "Print", "exec", "grim -g \"$(slurp)\" - | wl-copy")
hl.bind("CTRL","Print", "exec", "grim - | wl-copy")

-- [[ DPMS ]]
hl.bind(M .. "+SHIFT", "P", "dpms", "toggle")
