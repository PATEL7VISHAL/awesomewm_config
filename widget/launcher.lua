local beautiful = require('beautiful')
local hotkeys_popup = require("awful.hotkeys_popup")
local awful = require('awful')
local apps = require('configuration.apps')


-- {{{ Menu
-- Create a launcher widget and a main menu
local terminal = apps.default.terminal
local editor_cmd = terminal .. " -e " .. apps.default.editor

local myawesomemenu = {
    { "hotkeys",     function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual",      terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart",     awesome.restart },
    { "quit",        function() awesome.quit() end },
}

local mymainmenu = awful.menu({
    items = {
        { "awesome",       myawesomemenu,        beautiful.awesome_icon },
        { "open terminal", terminal },
        { "apps",          apps.default.launcher } --* we can add the launcher icon
    }
})

return awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = mymainmenu
})
