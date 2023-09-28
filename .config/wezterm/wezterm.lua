local wezterm = require("wezterm")

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
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = wezterm.action({ CompleteSelection = "PrimarySelection" }),
	},
	-- and make CTRL-Click open hyperlinks
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "SUPER",
		action = "OpenLinkAtMouseCursor",
	},
}

wezterm.on("toggle-ligature", function(window, _)
	local overrides = window:get_config_overrides() or {}
	if not overrides.harfbuzz_features then
		-- If we haven't overridden it yet, then override with ligatures disabled
		overrides.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
	else
		-- else we did already, and we should disable out override now
		overrides.harfbuzz_features = nil
	end
	window:set_config_overrides(overrides)
end)

local keys = {
	{ key = "=", mods = "SUPER", action = "IncreaseFontSize" },
	{ key = "-", mods = "SUPER", action = "DecreaseFontSize" },
	{ key = "0", mods = "SUPER", action = "ResetFontSize" },
	{ key = "X", mods = "SUPER|SHIFT", action = "ActivateCopyMode" },
	{ key = "N", mods = "SUPER|SHIFT", action = "SpawnWindow" },
	{ key = "Enter", mods = "ALT", action = "ToggleFullScreen" },
	{ key = " ", mods = "SHIFT|SUPER", action = "QuickSelect" },
	-- { key="F", mods="CTRL|SHIFT", action=wezterm.action{Search={CaseSensitiveString=""}} },

	-- { key = "W",     mods = "SUPER|SHIFT", action = wezterm.action { CloseCurrentTab = { confirm = true } } },
	{ key = "q", mods = "SUPER", action = wezterm.action({ CloseCurrentTab = { confirm = true } }) },
	{ key = "T", mods = "SUPER|SHIFT", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
	{ key = "Tab", mods = "CTRL", action = wezterm.action({ ActivateTabRelative = 1 }) },
	{ key = "Tab", mods = "CTRL|SHIFT", action = wezterm.action({ ActivateTabRelative = -1 }) },
	{ key = "c", mods = "SUPER", action = wezterm.action({ CopyTo = "Clipboard" }) },
	{ key = "v", mods = "SUPER", action = wezterm.action({ PasteFrom = "Clipboard" }) },
	{ key = "E", mods = "SUPER|SHIFT", action = wezterm.action.EmitEvent("toggle-ligature") },
}

local everforest_colors = {
	foreground = "#d3c6aa",
	-- background = "#2b3339",
	background = "#272e33",
	selection_bg = "#3B5360",
	scrollbar_thumb = "#222222",
	ansi = { "#4b565c", "#e67e80", "#a7c080", "#dbbc7f", "#7fbbb3", "#d699b6", "#83c092", "#d3c6aa" },
	brights = { "#4b565c", "#e67e80", "#a7c080", "#dbbc7f", "#7fbbb3", "#d699b6", "#83c092", "#d3c6aa" },
}

local config = wezterm.config_builder()

config.window_padding = window_padding
-- window_decorations = "NONE"
config.window_background_opacity = 1.0
config.adjust_window_size_when_changing_font_size = false

config.mouse_bindings = mouse_bindings
config.disable_default_key_bindings = true
config.keys = keys

config.force_reverse_video_cursor = true
config.enable_tab_bar = false

config.colors = everforest_colors
-- config.color_scheme = "Gruvbox Material (Gogh)"
config.font = wezterm.font_with_fallback({ family = "JetBrains Mono" })
config.font_size = 14.6
config.use_ime = false

return config
