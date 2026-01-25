local wezterm = require("wezterm")

----------------------------------------------------------------------------
-- PLATFORM DETECTION
----------------------------------------------------------------------------
local WINDOWS = wezterm.target_triple == "x86_64-pc-windows-msvc"
local MAC = wezterm.target_triple:find("apple") ~= nil
local LINUX = not WINDOWS and not MAC

----------------------------------------------------------------------------
-- HELPER FUNCTIONS
----------------------------------------------------------------------------
local function recompute_padding(window)
    local window_dims = window:get_dimensions()
    local overrides = window:get_config_overrides() or {}

    if not window_dims.is_full_screen then
        if not overrides.window_padding then
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
            return
        end
        overrides.window_padding = new_padding
    end
    window:set_config_overrides(overrides)
end

----------------------------------------------------------------------------
-- EVENT HANDLERS
----------------------------------------------------------------------------
wezterm.on("toggle-ligature", function(window, _)
    local overrides = window:get_config_overrides() or {}
    if not overrides.harfbuzz_features then
        overrides.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
    else
        overrides.harfbuzz_features = nil
    end
    window:set_config_overrides(overrides)
end)

if MAC or LINUX then
    wezterm.on("window-resized", function(window, _)
        recompute_padding(window)
    end)

    wezterm.on("window-config-reloaded", function(window)
        recompute_padding(window)
    end)
end

----------------------------------------------------------------------------
-- BASE CONFIGURATION
----------------------------------------------------------------------------
local mouse_bindings = {
    {
        event = { Up = { streak = 1, button = "Left" } },
        mods = "NONE",
        action = wezterm.action.CompleteSelection("PrimarySelection"),
    },
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

local config = wezterm.config_builder()

config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.native_macos_fullscreen_mode = true
config.adjust_window_size_when_changing_font_size = false

config.color_scheme = "Gruvbox Material (Gogh)"

config.window_background_opacity = 1.0

config.disable_default_key_bindings = true
config.force_reverse_video_cursor = true
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_ime = false

config.window_padding = {
    left = "0.8cell",
    right = "0.1cell",
    top = "1.4cell",
    bottom = "0cell",
}
config.mouse_bindings = mouse_bindings
config.keys = keys

config.font = wezterm.font_with_fallback({
    { family = "JetBrains Mono" },
    { family = "Microsoft YaHei", scale = 1.1 },
})

config.font_size = 16.4
config.front_end = "OpenGL"
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"

----------------------------------------------------------------------------
-- WINDOWS OVERRIDES
----------------------------------------------------------------------------
if WINDOWS then
    local wsl_domains = wezterm.default_wsl_domains()

    for _, dom in ipairs(wsl_domains) do
        if dom.name == "WSL:Arch" then
            dom.default_cwd = "/home/huibo"
        end
    end

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
        { key = "Enter", mods = "SHIFT",      action = wezterm.action.SendString("\x1b\r") },
    }

    for _, binding in ipairs(config.mouse_bindings) do
        if binding.mods == "SUPER" then
            binding.mods = "ALT"
        end
    end

    config.window_decorations = "TITLE | RESIZE"
    config.wsl_domains = wsl_domains
    config.default_domain = "WSL:archlinux"
    config.window_padding = {
        left = "0.5cell",
        right = "0.5cell",
        top = "8px",
        bottom = "0.5px",
    }
    config.font_size = 12.4
end

----------------------------------------------------------------------------
-- MACOS OVERRIDES
----------------------------------------------------------------------------
if MAC then
    -- Add macOS-specific overrides here
end

----------------------------------------------------------------------------
-- LINUX OVERRIDES
----------------------------------------------------------------------------
if LINUX then
    -- Add Linux-specific overrides here
end

return config
