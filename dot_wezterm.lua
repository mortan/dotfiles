local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

config.default_prog = { "pwsh.exe", "-NoLogo" }
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font('FiraCode Nerd Font Mono')
config.font_size = 12

config.leader = {
  key = "b",
  mods = "CTRL",
  timeout_milliseconds = 1000,
}

config.keys = {
  {
    key = "phys:1",
    mods = "ALT",
    action = act.ActivateTab(0),
  },
  {
    key = "phys:2",
    mods = "ALT",
    action = act.ActivateTab(1),
  },
  {
    key = "phys:3",
    mods = "ALT",
    action = act.ActivateTab(2),
  },
  {
    key = "phys:4",
    mods = "ALT",
    action = act.ActivateTab(3),
  },
  {
    key = "phys:5",
    mods = "ALT",
    action = act.ActivateTab(4),
  },
  {
    key = "phys:6",
    mods = "ALT",
    action = act.ActivateTab(5),
  },
  {
    key = "phys:7",
    mods = "ALT",
    action = act.ActivateTab(6),
  },
  {
    key = "phys:8",
    mods = "ALT",
    action = act.ActivateTab(7),
  },
  {
    key = "phys:9",
    mods = "ALT",
    action = act.ActivateTab(8),
  },
  {
    key = "l",
    mods = "LEADER",
    action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "j",
    mods = "LEADER",
    action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "h",
    mods = "ALT",
    action = act.ActivatePaneDirection("Left"),
  },
  {
    key = "j",
    mods = "ALT",
    action = act.ActivatePaneDirection("Down"),
  },
  {
    key = "k",
    mods = "ALT",
    action = act.ActivatePaneDirection("Up"),
  },
  {
    key = "l",
    mods = "ALT",
    action = act.ActivatePaneDirection("Right"),
  },
  {
    key = "H",
    mods = "ALT|SHIFT",
    action = act.AdjustPaneSize({ "Left", 5 }),
  },
  {
    key = "J",
    mods = "ALT|SHIFT",
    action = act.AdjustPaneSize({ "Down", 5 }),
  },
  {
    key = "K",
    mods = "ALT|SHIFT",
    action = act.AdjustPaneSize({ "Up", 5 }),
  },
  {
    key = "L",
    mods = "ALT|SHIFT",
    action = act.AdjustPaneSize({ "Right", 5 }),
  },
  {
    key = "x",
    mods = "LEADER",
    action = act.CloseCurrentPane({ confirm = true }),
  },
  {
    key = "z",
    mods = "LEADER",
    action = act.TogglePaneZoomState,
  },
}

wezterm.on("gui-startup", function(cmd)
   local _, _, window = wezterm.mux.spawn_window(cmd or {})
   window:gui_window():maximize()
 end)

return config
