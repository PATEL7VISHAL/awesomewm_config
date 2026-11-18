local beautiful = require("beautiful")
local windows = require("config.windows")

local M = {}

function M.setup(settings)
    beautiful.init(settings.theme)
    beautiful.border_width = windows.client_border_width
    beautiful.border_width_active = windows.client_border_width
    beautiful.border_width_normal = windows.client_border_width
    beautiful.border_width_maximized = 0
    beautiful.border_width_fullscreen = 0
    beautiful.border_color = windows.client_border_color_inactive
    beautiful.border_color_active = windows.client_border_color
    beautiful.border_color_normal = windows.client_border_color_inactive
    beautiful.border_color_floating_active = windows.client_border_color
    beautiful.border_color_floating_normal = windows.client_border_color_inactive
    beautiful.border_color_maximized = "#00000000"
    beautiful.border_color_fullscreen = "#00000000"
end

return M
