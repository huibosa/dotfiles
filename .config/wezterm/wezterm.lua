local wezterm = require 'wezterm'

local window_padding = {
  left = "0.2cell",
  right = "0.1cell",
  top = "0.2cell",
  bottom = "0cell",
}

local mouse_bindings = {
  -- Change the default click behavior so that it only selects
  -- text and doesn't open hyperlinks
  {
    event={Up={streak=1, button="Left"}},
    mods="NONE",
    action=wezterm.action{CompleteSelection="PrimarySelection"},
  },
  -- and make CTRL-Click open hyperlinks
  {
    event={Up={streak=1, button="Left"}},
    mods="CTRL",
    action="OpenLinkAtMouseCursor",
  },
}

wezterm.on("toggle-ligature", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if not overrides.harfbuzz_features then
    -- If we haven't overridden it yet, then override with ligatures disabled
    overrides.harfbuzz_features =  {"calt=0", "clig=0", "liga=0"}
  else
    -- else we did already, and we should disable out override now
    overrides.harfbuzz_features = nil
  end
  window:set_config_overrides(overrides)
end)

local keys = {
  { key='=', mods="CTRL", action="IncreaseFontSize" },
  { key='-', mods="CTRL", action="DecreaseFontSize" },
  { key='0', mods="CTRL", action="ResetFontSize" },

  { key="X", mods="CTRL|SHIFT", action="ActivateCopyMode" },
  { key="N", mods="CTRL|SHIFT", action="SpawnWindow" },
  { key="Enter", mods="ALT", action="ToggleFullScreen" },
  { key=" ", mods="SHIFT|CTRL", action="QuickSelect" },
  -- { key="F", mods="CTRL|SHIFT", action=wezterm.action{Search={CaseSensitiveString=""}} },

  { key="W", mods="CTRL|SHIFT", action=wezterm.action{CloseCurrentTab={confirm=true}} },
  { key="T", mods="CTRL|SHIFT", action=wezterm.action{SpawnTab="CurrentPaneDomain"} },
  { key="Tab", mods="CTRL", action=wezterm.action{ActivateTabRelative=1} },
  { key="Tab", mods="CTRL|SHIFT", action=wezterm.action{ActivateTabRelative=-1} },

  { key="C", mods="CTRL|SHIFT", action=wezterm.action{CopyTo="Clipboard"} },
  { key="V", mods="CTRL|SHIFT", action=wezterm.action{PasteFrom="Clipboard"} },

  { key="E", mods="CTRL|SHIFT", action=wezterm.action.EmitEvent("toggle-ligature") },
}

local colors = {
  foreground = "#d3c6aa",
  background = "#2b3339",
  selection_bg = "#3B5360",
  scrollbar_thumb = "#222222",
  ansi = {"#4b565c", "#e67e80", "#a7c080", "#dbbc7f", "#7fbbb3", "#d699b6", "#83c092", "#d3c6aa"},
  brights = {"#4b565c", "#e67e80", "#a7c080", "#dbbc7f", "#7fbbb3", "#d699b6", "#83c092", "#d3c6aa"},
}

return {
  window_padding = window_padding,
  window_decorations = "NONE",
  window_background_opacity = 1.0,
  adjust_window_size_when_changing_font_size = false,

  mouse_bindings = mouse_bindings,
  disable_default_key_bindings = true,
  keys = keys,

  force_reverse_video_cursor = true,
  enable_tab_bar = false,

  colors = colors,
  font = wezterm.font_with_fallback({
    {
      family="JetBrains Mono",
    },
    {
      family="Microsoft YaHei",
    }
  }),
  font_size = 14.6,
}
