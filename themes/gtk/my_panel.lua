local awful = require('awful')
local wibox = require('wibox')
local beautiful = require('beautiful')
local gears = require('gears')
local client = require('awful.client')
local taskLists = require('widget.tasklist')
-- local taskLists2 = require('widget.tasklist2')
local tagList = require('widget.taglist')
-- local tagList2 = require('widget.taglist2')
local mytextclock = require('widget.textclock')
local mylauncher = require('widget.launcher')
local cpu_widget = require('awesome-wm-widgets.cpu-widget.cpu-widget')
local ram_widget = require("awesome-wm-widgets.ram-widget.ram-widget")
local logout_menu_widget = require("awesome-wm-widgets.logout-menu-widget.logout-menu")
local separators = require('widget.utils.separators')
local mylayoutbox = require('widget.layout-button')
local mysystray = require('widget.systray')
local theme = require('themes.gtk.theme')
local net_speed_widget = require("awesome-wm-widgets.net-speed-widget.net-speed")

local app_launcher = require('bling.widget.app_launcher')
local window_switcher = require('bling.widget.window_switcher')

-- local bg_color = beautiful.gtk.get_theme_variables().bg_color

root.buttons(gears.table.join(
-- awful.button({}, 3, function() mymainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))


-- Create the wibox
awful.screen.connect_for_each_screen(function(s)
    -- s.mywibox = awful.wibar({ border_width = 0, border_color = bg_color, height = 25, position = "bottom", screen = s })
    s.mywibox = awful.wibar({ border_width = 0, border_color = "#327777", height = 25, position = "bottom", screen = s })
    -- Add widgets to the wibox
    s.mywibox:setup {

        layout = wibox.layout.align.horizontal,
        expand = "none",

        {
            -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            -- mylauncher,
            tagList(s),
            separators.dot(s, {
                width = 8,
                left = 8,
                right = 5,
                color = '#00caca98'
            }),
            taskLists.icon_only(s),
            -- s.mypromptbox,
        },

        {
            layout = wibox.layout.fixed.horizontal,
            taskLists.icon_with_title(s),
            separators.dot(s, {
                width = 8,
                left = 8,
                right = 0,
                color = '#009aba98'
            }),
            mytextclock,
        },

        {
            -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            net_speed_widget({ screen = s }),
            -- app_launcher({ screen = s }),
            -- tag_preview({ screen = s }),
            -- task_preview({ screen = s }),
            -- window_switcher({ screen = s }),
            cpu_widget({
                width = 60,
                step_width = 2,
                step_spacing = 2,
                -- color = '#434c5e'
                color = '#7afafa'
            }),
            ram_widget({
                color_used = '#fefefe',
                color_free = '#55a055',
                color_buf = '#f0f30a',
            }),
            mylayoutbox(s),
            mysystray,
            logout_menu_widget()
        },
    }
end)
