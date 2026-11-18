local awful = require("awful")
local gears = require("gears")
local windows = require("config.windows")

local M = {}

local function uses_maximized_layout(c)
    local t = c.first_tag
    local layout = t and t.layout

    return layout == awful.layout.suit.max
        or layout == awful.layout.suit.max.fullscreen
end

local function is_popup(c)
    local client_type = c.type
    local role = (c.role or ""):lower()

    return c.transient_for ~= nil
        or client_type == "dialog"
        or client_type == "utility"
        or client_type == "splash"
        or client_type == "toolbar"
        or client_type == "menu"
        or client_type == "dropdown_menu"
        or client_type == "popup_menu"
        or client_type == "tooltip"
        or client_type == "notification"
        or role:find("pop-up", 1, true) ~= nil
        or role:find("popup", 1, true) ~= nil
        or role:find("menu", 1, true) ~= nil
        or role:find("dialog", 1, true) ~= nil
end

local function rounded_shape(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, windows.client_corner_radius)
end

local function update(c)
    local fullscreen = c.fullscreen
        or c.maximized
        or c.maximized_horizontal
        or c.maximized_vertical
        or uses_maximized_layout(c)
    local popup = is_popup(c)

    c.shape = fullscreen and gears.shape.rectangle or rounded_shape
    c.border_width = (fullscreen or popup) and 0 or windows.client_border_width
    c.border_color = c.active
        and windows.client_border_color
        or windows.client_border_color_inactive
end

function M.setup()
    client.connect_signal("request::border", update)
    client.connect_signal("request::manage", update)
    client.connect_signal("property::role", update)
    client.connect_signal("property::type", update)

    tag.connect_signal("property::layout", function(t)
        for _, c in ipairs(t:clients()) do
            update(c)
        end
    end)
end

return M
