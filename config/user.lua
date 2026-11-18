local gears = require("gears")
local keys = require("config.keys.mod")
local apps = require("config.apps")

local M = {}

M.terminal = apps.default.terminal
M.editor = apps.default.editor
M.editor_cmd = M.editor
M.apps = apps
M.modkey = keys.modKey
M.altkey = keys.altKey
M.theme = gears.filesystem.get_themes_dir() .. "default/theme.lua"

return M
