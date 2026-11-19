local gears = require("gears")
local keys = require("config.keys.mod")
local apps = require("config.apps")

---@type UserSettings
local M = {
    terminal = apps.default.terminal,
    editor = apps.default.editor,
    editor_cmd = apps.default.editor,
    apps = apps,
    modkey = keys.modKey,
    altkey = keys.altKey,
    theme = gears.filesystem.get_themes_dir() .. "default/theme.lua",
}

return M
