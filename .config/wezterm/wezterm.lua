local wezterm = require("wezterm")

-- Import platform modules
local platform = require("config.platform")
local base = require("config.base")
local windows = require("config.windows")
local macos = require("config.macos")
local linux = require("config.linux")

-- Event handler for toggling ligatures (available on all platforms)
wezterm.on("toggle-ligature", function(window, _)
    local overrides = window:get_config_overrides() or {}
    if not overrides.harfbuzz_features then
        overrides.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
    else
        overrides.harfbuzz_features = nil
    end
    window:set_config_overrides(overrides)
end)

-- Create base configuration
local config = base.base_config()

-- Apply platform-specific configuration
if platform.WINDOWS then
    windows.win_config(config)
elseif platform.MAC then
    macos.setup_event_handlers()
elseif platform.LINUX then
    linux.setup_event_handlers()
end

return config