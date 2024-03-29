local wezterm = require("wezterm")

local win_config = function(config)
	local wsl_domains = wezterm.default_wsl_domains()

	for _, dom in ipairs(wsl_domains) do
		if dom.name == "WSL:Arch" then
			dom.default_cwd = "/home/huibo"
		end
	end

	local window_padding = {
		left = "0.5cell",
		right = "0.5cell",
		top = "8px",
		bottom = "0.5px",
	}

	for _, key in ipairs(config.keys) do
		if key.mods == "SUPER" then
			if key.key == "c" or key.key == "v" then
				key.mods = "CTRL|SHIFT"
			else
				key.mods = "CTRL"
			end
		elseif key.mods == "SUPER|SHIFT" then
			key.mods = "CTRL|SHIFT"
		end
	end

	for _, binding in ipairs(config.mouse_bindings) do
		if binding.mods == "SUPER" then
			binding.mods = "CTRL"
		end
	end

	config.window_decorations = "TITLE | RESIZE"
	config.wsl_domains = wsl_domains
	config.default_domain = "WSL:Arch"
	config.window_padding = window_padding
	config.font_size = 12.0

	return config
end

local base_config = function()
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

	local keys = {
		{ key = "=", mods = "SUPER", action = "IncreaseFontSize" },
		{ key = "-", mods = "SUPER", action = "DecreaseFontSize" },
		{ key = "0", mods = "SUPER", action = "ResetFontSize" },

		{ key = "X", mods = "SUPER|SHIFT", action = "ActivateCopyMode" },
		{ key = " ", mods = "SUPER|SHIFT", action = "QuickSelect" },

		{ key = "Enter", mods = "ALT", action = "ToggleFullScreen" },
		{ key = "N", mods = "SUPER|SHIFT", action = "SpawnWindow" },

		{ key = "W", mods = "SUPER|SHIFT", action = wezterm.action({ CloseCurrentTab = { confirm = true } }) },
		{ key = "T", mods = "SUPER|SHIFT", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
		{ key = "Tab", mods = "SUPER", action = wezterm.action({ ActivateTabRelative = 1 }) },
		{ key = "Tab", mods = "SUPER|SHIFT", action = wezterm.action({ ActivateTabRelative = -1 }) },

		-- { key = "F", mods = "SUPER|SHIFT", action = wezterm.action({ Search = { CaseSensitiveString = "" } }) },

		{ key = "c", mods = "SUPER", action = wezterm.action({ CopyTo = "Clipboard" }) },
		{ key = "v", mods = "SUPER", action = wezterm.action({ PasteFrom = "Clipboard" }) },

		{ key = "E", mods = "SUPER|SHIFT", action = wezterm.action.EmitEvent("toggle-ligature") },
	}

	local window_padding = {
		left = "0.8cell",
		right = "0.1cell",
		top = "1.4cell",
		bottom = "0cell",
	}

	local everforest_colors = {
		foreground = "#d3c6aa",
		-- background = "#2b3339",
		background = "#272e33",
		selection_bg = "#3B5360",
		scrollbar_thumb = "#222222",
		ansi = { "#4b565c", "#e67e80", "#a7c080", "#dbbc7f", "#7fbbb3", "#d699b6", "#83c092", "#d3c6aa" },
		brights = { "#4b565c", "#e67e80", "#a7c080", "#dbbc7f", "#7fbbb3", "#d699b6", "#83c092", "#d3c6aa" },
		indexed = { [16] = "#ffa066", [17] = "#ff5d62" },
	}

	local config = wezterm.config_builder()

	config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
	config.native_macos_fullscreen_mode = true
	config.adjust_window_size_when_changing_font_size = false

	config.colors = everforest_colors
	config.window_background_opacity = 1.0

	config.disable_default_key_bindings = true
	config.force_reverse_video_cursor = true
	config.enable_tab_bar = false
	config.use_ime = false

	config.window_padding = window_padding
	config.mouse_bindings = mouse_bindings
	config.keys = keys

	config.font = wezterm.font_with_fallback({
		{ family = "JetBrains Mono" },
		{ family = "Microsoft YaHei" },
	})

	-- config.font_size = 14.8
	config.font_size = 16.4

	return config
end

local os_uname = function()
	local sep = package.config:sub(1, 1)
	return (sep == "/") and "UNIX" or "WIN"
end

local function recompute_padding(window)
	local window_dims = window:get_dimensions()
	local overrides = window:get_config_overrides() or {}

	if not window_dims.is_full_screen then
		if not overrides.window_padding then
			-- not changing anything
			return
		end
		overrides.window_padding = nil
	else
		local new_padding = {
			left = "0.7cell",
			right = "0.1cell",
			top = "0.2cell",
			bottom = "0cell",
		}
		if
			overrides.window_padding
			and new_padding.left == overrides.window_padding.left
			and new_padding.right == overrides.window_padding.right
			and new_padding.top == overrides.window_padding.top
			and new_padding.bottom == overrides.window_padding.bottom
		then
			-- padding is same, avoid triggering further changes
			return
		end
		overrides.window_padding = new_padding
	end
	window:set_config_overrides(overrides)
end

-------------------------------------------------------------------------------

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

-------------------------------------------------------------------------------

local config = base_config()

if os_uname() == "WIN" then
	win_config(config)
else
	wezterm.on("window-resized", function(window, _)
		recompute_padding(window)
	end)

	wezterm.on("window-config-reloaded", function(window)
		recompute_padding(window)
	end)
end

return config
