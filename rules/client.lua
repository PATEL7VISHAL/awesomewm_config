local awful = require("awful")
local gears = require("gears")
local ruled = require("ruled")
local windows = require("config.windows")

local M = {}

local function rounded_shape(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, windows.floating_corner_radius)
end

local function fit_to_workarea(c)
    local workarea = c.screen and c.screen.workarea
    if not workarea then
        return
    end

    local geometry = c:geometry()
    local max_width = math.floor(workarea.width * windows.dialog_max_width_ratio)
    local max_height = math.floor(workarea.height * windows.dialog_max_height_ratio)

    if geometry.width > max_width or geometry.height > max_height then
        c:geometry({
            width = math.min(geometry.width, max_width),
            height = math.min(geometry.height, max_height),
        })
    end

    awful.placement.no_offscreen(c, { honor_workarea = true })
end

local function center_dialog(c)
    fit_to_workarea(c)
    awful.placement.centered(c, { honor_workarea = true })
end

function M.setup()
    ruled.client.connect_signal("request::rules", function()
        ruled.client.append_rule({
            id = "global",
            rule = {},
            properties = {
                focus = awful.client.focus.filter,
                raise = true,
                screen = awful.screen.preferred,
                placement = awful.placement.no_overlap + awful.placement.no_offscreen,
                floating = false,
                maximized = false,
                above = false,
                below = false,
                ontop = false,
                sticky = false,
                maximized_horizontal = false,
                maximized_vertical = false,
            },
        })

        ruled.client.append_rule({
            id = "titlebars",
            rule_any = {
                type = { "normal" },
            },
            properties = {
                titlebars_enabled = true,
            },
        })

        ruled.client.append_rule({
            id = "quake-terminal",
            rule_any = {
                name = { "QuakeTerminal" },
            },
            properties = {
                titlebars_enabled = false,
            },
        })

        ruled.client.append_rule({
            id = "floating",
            rule_any = {
                instance = { "copyq", "pinentry" },
                class = {
                    "Arandr",
                    "Blueman-manager",
                    "Gpick",
                    "Kruler",
                    "Sxiv",
                    "Tor Browser",
                    "Wpa_gui",
                    "veromix",
                    "xtightvncviewer",
                    "netsoft-com.netsoft.hubstaff",
                    "Netsoft-com.netsoft.hubstaff",
                },
                name = { "Event Tester" },
                role = {
                    "AlarmWindow",
                    "ConfigManager",
                },
            },
            properties = {
                floating = true,
            },
        })

        ruled.client.append_rule({
            id = "dialog",
            rule_any = {
                type = { "dialog", "splash", "utility" },
                class = {
                    "Wicd-client.py",
                    "calendar.google.com",
                },
            },
            properties = {
                floating = true,
                ontop = true,
                fullscreen = false,
                maximized = false,
                maximized_horizontal = false,
                maximized_vertical = false,
                size_hints_honor = false,
                titlebars_enabled = false,
                shape = rounded_shape,
            },
            callback = center_dialog,
        })

        ruled.client.append_rule({
            id = "popup",
            rule_any = {
                role = {
                    "pop-up",
                    "GtkMenu",
                    "menu",
                },
            },
            properties = {
                floating = true,
                ontop = true,
                fullscreen = false,
                maximized = false,
                maximized_horizontal = false,
                maximized_vertical = false,
                titlebars_enabled = false,
                shape = rounded_shape,
            },
            callback = fit_to_workarea,
        })

        ruled.client.append_rule({
            id = "hubstaff",
            rule_any = {
                class = {
                    "netsoft-com.netsoft.hubstaff",
                    "Netsoft-com.netsoft.hubstaff",
                },
            },
            properties = {
                tag = "5",
                floating = true,
                titlebars_enabled = false,
            },
        })

        ruled.client.append_rule({
            id = "telegram",
            rule_any = {
                class = { "TelegramDesktop" },
            },
            properties = {
                tag = "5",
                titlebars_enabled = false,
            },
        })

    end)
end

return M
