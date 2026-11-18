local gears = require("gears")

local M = {}

M.terminal = "xterm"
M.editor = os.getenv("EDITOR") or "nano"
M.editor_cmd = M.terminal .. " -e " .. M.editor
M.modkey = "Mod4"
M.theme = gears.filesystem.get_themes_dir() .. "default/theme.lua"

return M
