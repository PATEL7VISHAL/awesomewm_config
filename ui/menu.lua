local awful = require("awful")
local beautiful = require("beautiful")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

local M = {}

function M.build(settings)
    local awesome_menu = {
        { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
        { "manual", settings.terminal .. " -e man awesome" },
        { "edit config", settings.editor_cmd .. " " .. awesome.conffile },
        { "restart", awesome.restart },
        { "quit", function() awesome.quit() end },
    }

    local main_menu = awful.menu({
        items = {
            { "awesome", awesome_menu, beautiful.awesome_icon },
            { "open terminal", settings.terminal },
        },
    })

    local launcher = awful.widget.launcher({
        image = beautiful.awesome_icon,
        menu = main_menu,
    })

    menubar.utils.terminal = settings.terminal

    return {
        main = main_menu,
        launcher = launcher,
    }
end

return M
