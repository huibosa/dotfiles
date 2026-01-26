local wezterm = require("wezterm")

----------------------------------------------------------------------------
-- PLATFORM DETECTION
----------------------------------------------------------------------------
local WINDOWS = wezterm.target_triple == "x86_64-pc-windows-msvc"
local MAC = wezterm.target_triple:find("apple") ~= nil
local LINUX = not WINDOWS and not MAC

----------------------------------------------------------------------------
-- THEME CONSTANTS
----------------------------------------------------------------------------
local THEME = {
    bg_dark = "#1d2021",
    bg_normal = "#282828",
    fg_active = "#c0c0c0",
    fg_inactive = "#808080",
    hover_bg = "#3b3052",
    hover_fg = "#909090",
}

local PADDING = {
    default = {
        left = "0.8cell",
        right = "0.1cell",
        top = "1.4cell",
        bottom = "0cell",
    },
    fullscreen = {
        left = "0.7cell",
        right = "0.1cell",
        top = "0.2cell",
        bottom = "0cell",
    },
    windows = {
        left = "0.5cell",
        right = "0.5cell",
        top = "8px",
        bottom = "0.5px",
    },
}

local FONT_SIZE = {
    default = 16.4,
    windows = 12.4,
}

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
        local new_padding = PADDING.fullscreen
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

--- Generate key bindings with platform-appropriate modifier
---@param mod string Primary modifier ("SUPER" for Mac/Linux, "ALT" for Windows)
---@return table
local function make_keys(mod)
    return {
        -- Font size
        { key = "=",     mods = mod,          action = wezterm.action.IncreaseFontSize },
        { key = "-",     mods = mod,          action = wezterm.action.DecreaseFontSize },
        { key = "0",     mods = mod,          action = wezterm.action.ResetFontSize },
        { key = "=",     mods = "CTRL",       action = wezterm.action.IncreaseFontSize },
        { key = "-",     mods = "CTRL",       action = wezterm.action.DecreaseFontSize },
        { key = "0",     mods = "CTRL",       action = wezterm.action.ResetFontSize },

        -- Modes
        { key = "X",     mods = "CTRL|SHIFT", action = wezterm.action.ActivateCopyMode },
        { key = " ",     mods = "CTRL|SHIFT", action = wezterm.action.QuickSelect },

        -- Window management
        { key = "Enter", mods = mod,          action = wezterm.action.ToggleFullScreen },
        { key = "n",     mods = mod,          action = wezterm.action.SpawnWindow },
        { key = "q",     mods = mod,          action = wezterm.action.QuitApplication },
        { key = "h",     mods = mod,          action = wezterm.action.Hide },

        -- Tab management
        { key = "w",     mods = mod,          action = wezterm.action.CloseCurrentTab({ confirm = true }) },
        { key = "t",     mods = mod,          action = wezterm.action.SpawnTab("CurrentPaneDomain") },
        { key = "Tab",   mods = "CTRL",       action = wezterm.action.ActivateTabRelative(1) },
        { key = "Tab",   mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },

        -- Search
        { key = "f",     mods = mod,          action = wezterm.action({ Search = { CaseSensitiveString = "" } }) },

        -- Clipboard
        { key = "c",     mods = mod,          action = wezterm.action.CopyTo("Clipboard") },
        { key = "v",     mods = mod,          action = wezterm.action.PasteFrom("Clipboard") },
        { key = "C",     mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") },
        { key = "V",     mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom("Clipboard") },

        -- Misc
        { key = "E",     mods = "CTRL|SHIFT", action = wezterm.action.EmitEvent("toggle-ligature") },
        { key = "Enter", mods = "SHIFT",      action = wezterm.action.SendString("\x1b\r") },
    }
end

--- Generate mouse bindings with platform-appropriate modifier
---@param mod string Primary modifier ("SUPER" for Mac/Linux, "ALT" for Windows)
---@return table
local function make_mouse_bindings(mod)
    return {
        {
            event = { Up = { streak = 1, button = "Left" } },
            mods = "NONE",
            action = wezterm.action.CompleteSelection("PrimarySelection"),
        },
        {
            event = { Up = { streak = 1, button = "Left" } },
            mods = mod,
            action = wezterm.action.OpenLinkAtMouseCursor,
        },
    }
end

--- Build tab bar colors using theme constants
---@return table
local function make_tab_bar_colors()
    return {
        background = THEME.bg_dark,
        active_tab = {
            bg_color = THEME.bg_normal,
            fg_color = THEME.fg_active,
            intensity = "Normal",
            underline = "None",
            italic = false,
            strikethrough = false,
        },
        inactive_tab = {
            bg_color = THEME.bg_dark,
            fg_color = THEME.fg_inactive,
        },
        inactive_tab_hover = {
            bg_color = THEME.hover_bg,
            fg_color = THEME.hover_fg,
            italic = true,
        },
        new_tab = {
            bg_color = THEME.bg_dark,
            fg_color = THEME.fg_inactive,
        },
        new_tab_hover = {
            bg_color = THEME.hover_bg,
            fg_color = THEME.hover_fg,
            italic = true,
        },
    }
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
local mod = WINDOWS and "ALT" or "SUPER"

local config = wezterm.config_builder()

-- Window
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "RESIZE"
config.native_macos_fullscreen_mode = true
config.adjust_window_size_when_changing_font_size = false
config.window_background_opacity = 1.0
config.window_padding = PADDING.default

-- Appearance
config.color_scheme = "Gruvbox Material (Gogh)"
config.colors = { tab_bar = make_tab_bar_colors() }

-- Behavior
config.disable_default_key_bindings = true
config.force_reverse_video_cursor = true
-- config.enable_tab_bar = true
-- config.hide_tab_bar_if_only_one_tab = true
config.use_ime = false

-- Input
config.keys = make_keys(mod)
config.mouse_bindings = make_mouse_bindings(mod)

-- Font
config.font = wezterm.font_with_fallback({
    { family = "JetBrains Mono" },
    { family = "Microsoft YaHei", scale = 1.1 },
})
config.font_size = FONT_SIZE.default
config.front_end = "OpenGL"
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"

----------------------------------------------------------------------------
-- PLATFORM OVERRIDES
----------------------------------------------------------------------------
if WINDOWS then
    local wsl_domains = wezterm.default_wsl_domains()
    for _, dom in ipairs(wsl_domains) do
        if dom.name == "WSL:Arch" then
            dom.default_cwd = "/home/huibo"
        end
    end

    config.wsl_domains = wsl_domains
    config.default_domain = "WSL:archlinux"
    config.window_decorations = "TITLE | RESIZE"
    config.window_padding = PADDING.windows
    config.font_size = FONT_SIZE.windows

    -- Windows-specific: Shift+Enter sends escape sequence
    table.insert(config.keys, { key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\x1b\r") })
end

----------------------------------------------------------------------------
-- PLUGINS
----------------------------------------------------------------------------
wezterm.plugin
    .require("https://github.com/yriveiro/wezterm-tabs")
    .apply_to_config(config, {
        tabs = {
            tab_bar_at_bottom = false,
            hide_tab_bar_if_only_one_tab = true
        }
    })

return config
