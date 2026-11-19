local beautiful = require("beautiful")
local windows = require("config.windows")
local themes = require("config.themes")

local M = {}

function M.setup(settings)
    beautiful.init(settings.theme)
    local theme = themes.presets[themes.active]

    if not theme then
        error("Unknown Awesome theme '" .. tostring(themes.active) .. "'")
    end

    beautiful.panel_bg = theme.panel.bg
    beautiful.panel_fg = theme.panel.fg
    beautiful.panel_border = theme.panel.border
    beautiful.panel_accent = theme.panel.accent
    beautiful.panel_separator = theme.panel.separator
    beautiful.panel_indicator = theme.panel.indicator
    beautiful.widget_theme = theme.widgets
    beautiful.widget_fonts = theme.fonts
    beautiful.font = theme.fonts.base.string
    beautiful.battery_normal = theme.widgets.battery.normal
    beautiful.battery_charging = theme.widgets.battery.charging
    beautiful.battery_warning = theme.widgets.battery.warning
    beautiful.battery_critical = theme.widgets.battery.critical
    beautiful.battery_empty = theme.widgets.battery.empty
    beautiful.battery_label_fg = theme.widgets.battery.label
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
