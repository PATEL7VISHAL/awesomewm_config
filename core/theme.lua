local beautiful = require("beautiful")
local windows = require("config.windows")

local M = {}

function M.setup(settings)
    beautiful.init(settings.theme)
    beautiful.battery_normal = beautiful.battery_normal or "#A6E3A1"
    beautiful.battery_charging = beautiful.battery_charging or "#74C7EC"
    beautiful.battery_warning = beautiful.battery_warning or "#F9E2AF"
    beautiful.battery_critical = beautiful.battery_critical or "#F38BA8"
    beautiful.battery_empty = beautiful.battery_empty or "#717284"
    beautiful.battery_label_fg = beautiful.battery_label_fg
        or beautiful.panel_bg
        or beautiful.bg_normal
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
