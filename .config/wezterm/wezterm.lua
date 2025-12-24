local wezterm = require("wezterm")

local WINDOWS = wezterm.target_triple == "x86_64-pc-windows-msvc"
local MAC = wezterm.target_triple == "x86_64-apple-darwin" or wezterm.target_triple == "aarch64-apple-darwin"

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

    config.keys = {
        { key = "=",     mods = "ALT",        action = wezterm.action.IncreaseFontSize },
        { key = "-",     mods = "ALT",        action = wezterm.action.DecreaseFontSize },
        { key = "0",     mods = "ALT",        action = wezterm.action.ResetFontSize },
        { key = "=",     mods = "CTRL",       action = wezterm.action.IncreaseFontSize },
        { key = "-",     mods = "CTRL",       action = wezterm.action.DecreaseFontSize },
        { key = "0",     mods = "CTRL",       action = wezterm.action.ResetFontSize },

        { key = "X",     mods = "CTRL|SHIFT", action = wezterm.action.ActivateCopyMode },
        { key = " ",     mods = "CTRL|SHIFT", action = wezterm.action.QuickSelect },

        { key = "Enter", mods = "ALT",        action = wezterm.action.ToggleFullScreen },

        { key = "n",     mods = "ALT",        action = wezterm.action.SpawnWindow },
        { key = "q",     mods = "ALT",        action = wezterm.action.QuitApplication },
        { key = "h",     mods = "ALT",        action = wezterm.action.Hide },

        { key = "w",     mods = "ALT",        action = wezterm.action.CloseCurrentTab({ confirm = true }) },
        { key = "t",     mods = "ALT",        action = wezterm.action.SpawnTab("CurrentPaneDomain") },
        { key = "Tab",   mods = "CTRL",       action = wezterm.action.ActivateTabRelative(1) },
        { key = "Tab",   mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },

        { key = "f",     mods = "ALT",        action = wezterm.action({ Search = { CaseSensitiveString = "" } }) },

        { key = "c",     mods = "ALT",        action = wezterm.action.CopyTo("Clipboard") },
        { key = "v",     mods = "ALT",        action = wezterm.action.PasteFrom("Clipboard") },
        { key = "C",     mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") },
        { key = "V",     mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom("Clipboard") },

        { key = "E",     mods = "CTRL|SHIFT", action = wezterm.action.EmitEvent("toggle-ligature") },
    }

    for _, binding in ipairs(config.mouse_bindings) do
        if binding.mods == "SUPER" then
            binding.mods = "ALT"
        end
    end

    config.window_decorations = "TITLE | RESIZE"
    config.wsl_domains = wsl_domains
    config.default_domain = "WSL:Arch"
    config.window_padding = window_padding
    config.font_size = 12.4

    return config
end

local base_config = function()
    local mouse_bindings = {
        -- Change the default click behavior so that it only selects
        -- text and doesn't open hyperlinks
        {
            event = { Up = { streak = 1, button = "Left" } },
            mods = "NONE",
            action = wezterm.action.CompleteSelection("PrimarySelection"),
        },
        -- and make CTRL-Click open hyperlinks
        {
            event = { Up = { streak = 1, button = "Left" } },
            mods = "SUPER",
            action = wezterm.action.OpenLinkAtMouseCursor,
        },
    }

    local keys = {
        { key = "=",     mods = "SUPER",      action = wezterm.action.IncreaseFontSize },
        { key = "-",     mods = "SUPER",      action = wezterm.action.DecreaseFontSize },
        { key = "0",     mods = "SUPER",      action = wezterm.action.ResetFontSize },
        { key = "=",     mods = "CTRL",       action = wezterm.action.IncreaseFontSize },
        { key = "-",     mods = "CTRL",       action = wezterm.action.DecreaseFontSize },
        { key = "0",     mods = "CTRL",       action = wezterm.action.ResetFontSize },

        { key = "X",     mods = "CTRL|SHIFT", action = wezterm.action.ActivateCopyMode },
        { key = " ",     mods = "CTRL|SHIFT", action = wezterm.action.QuickSelect },

        { key = "Enter", mods = "SUPER",      action = wezterm.action.ToggleFullScreen },

        { key = "n",     mods = "SUPER",      action = wezterm.action.SpawnWindow },
        { key = "q",     mods = "SUPER",      action = wezterm.action.QuitApplication },
        { key = "h",     mods = "SUPER",      action = wezterm.action.Hide },

        { key = "w",     mods = "SUPER",      action = wezterm.action.CloseCurrentTab({ confirm = true }) },
        { key = "t",     mods = "SUPER",      action = wezterm.action.SpawnTab("CurrentPaneDomain") },
        { key = "Tab",   mods = "CTRL",       action = wezterm.action.ActivateTabRelative(1) },
        { key = "Tab",   mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },

        { key = "f",     mods = "SUPER",      action = wezterm.action({ Search = { CaseSensitiveString = "" } }) },

        { key = "c",     mods = "SUPER",      action = wezterm.action.CopyTo("Clipboard") },
        { key = "v",     mods = "SUPER",      action = wezterm.action.PasteFrom("Clipboard") },
        { key = "C",     mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") },
        { key = "V",     mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom("Clipboard") },

        { key = "E",     mods = "CTRL|SHIFT", action = wezterm.action.EmitEvent("toggle-ligature") },
    }

    local window_padding = {
        left = "0.8cell",
        right = "0.1cell",
        top = "1.4cell",
        bottom = "0cell",
    }

    local config = wezterm.config_builder()

    config.window_close_confirmation = "NeverPrompt"
    config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
    config.native_macos_fullscreen_mode = true
    config.adjust_window_size_when_changing_font_size = false

    config.color_scheme = "Gruvbox Material (Gogh)"
    -- config.color_scheme = "Everforest Dark (Gogh)"

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
        { family = "Microsoft YaHei", scale = 1.1 },
    })

    -- config.font_size = 14.8
    config.font_size = 16.4
    config.front_end = 'OpenGL'
    config.freetype_load_target = 'Light'
    config.freetype_render_target = 'HorizontalLcd'

    return config
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

if WINDOWS then
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
