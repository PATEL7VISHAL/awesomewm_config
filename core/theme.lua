local beautiful = require("beautiful")
local windows = require("config.windows")
local themes = require("config.themes")
local notifications = require("config.notifications")
local drawing = require("ui.panels.widgets.lib.drawing")
local gears = require("gears")

local M = {}

-- Publish tooltip and notification styling derived from the active panel palette.
local function setup_popups(theme)
    local panel = theme.panel
    local radius = windows.popup_corner_radius

    -- Slightly lifted surface, similar to an elevated material card.
    local surface = drawing.interpolate_color(panel.bg, panel.fg, 0.06)
    local muted = drawing.interpolate_color(panel.bg, panel.fg, 0.62)
    local indicator = panel.indicator or {}

    beautiful.tooltip_bg = surface
    beautiful.tooltip_fg = panel.fg
    beautiful.tooltip_border_color = panel.border
    beautiful.tooltip_border_width = windows.client_border_width
    beautiful.tooltip_font = theme.fonts.base.string
    beautiful.tooltip_accent = panel.accent
    beautiful.tooltip_muted = muted
    beautiful.tooltip_shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
    end

    beautiful.notification_bg = surface
    beautiful.notification_fg = panel.fg
    beautiful.notification_muted = muted
    beautiful.notification_border_color = panel.border
    beautiful.notification_border_width = windows.client_border_width
    beautiful.notification_font = theme.fonts.base.string
    beautiful.notification_max_width = notifications.width
    beautiful.notification_icon_size = notifications.icon_size
    beautiful.notification_position = notifications.position
    beautiful.notification_shape = beautiful.tooltip_shape
    beautiful.notification_accent_low = muted
    beautiful.notification_accent_normal = panel.accent
    beautiful.notification_accent_critical = indicator.urgent or panel.accent
end

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
    beautiful.exit_theme = theme.exit
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

    setup_popups(theme)
end

return M
