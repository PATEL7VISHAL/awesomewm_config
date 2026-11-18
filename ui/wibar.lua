local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local workspace_tags = require("ui.tags")

local M = {}

function M.setup(opts)
    local mykeyboardlayout = awful.widget.keyboardlayout()
    local mytextclock = wibox.widget.textclock()

    screen.connect_signal("request::desktop_decoration", function(s)
        workspace_tags.create_for_screen(s)

        s.mypromptbox = awful.widget.prompt()

        s.mylayoutbox = awful.widget.layoutbox({
            screen = s,
            buttons = {
                awful.button({}, 1, function() awful.layout.inc(1) end),
                awful.button({}, 3, function() awful.layout.inc(-1) end),
                awful.button({}, 4, function() awful.layout.inc(-1) end),
                awful.button({}, 5, function() awful.layout.inc(1) end),
            },
        })

        s.mytaglist = awful.widget.taglist({
            screen = s,
            filter = awful.widget.taglist.filter.all,
            buttons = {
                awful.button({}, 1, function(t) t:view_only() end),
                awful.button({ opts.modkey }, 1, function(t)
                    if client.focus then
                        client.focus:move_to_tag(t)
                    end
                end),
                awful.button({}, 3, awful.tag.viewtoggle),
                awful.button({ opts.modkey }, 3, function(t)
                    if client.focus then
                        client.focus:toggle_tag(t)
                    end
                end),
                awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
                awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end),
            },
        })

        s.mytasklist = awful.widget.tasklist({
            screen = s,
            filter = awful.widget.tasklist.filter.currenttags,
            buttons = {
                awful.button({}, 1, function(c)
                    c:activate({ context = "tasklist", action = "toggle_minimization" })
                end),
                awful.button({}, 3, function() awful.menu.client_list({ theme = { width = 250 } }) end),
                awful.button({}, 4, function() awful.client.focus.byidx(-1) end),
                awful.button({}, 5, function() awful.client.focus.byidx(1) end),
            },
        })

        s.mywibox = awful.wibar({
            position = "top",
            screen = s,
            widget = {
                layout = wibox.layout.align.horizontal,
                {
                    layout = wibox.layout.fixed.horizontal,
                    opts.launcher,
                    s.mytaglist,
                    s.mypromptbox,
                },
                s.mytasklist,
                {
                    layout = wibox.layout.fixed.horizontal,
                    mykeyboardlayout,
                    wibox.widget.systray(),
                    mytextclock,
                    s.mylayoutbox,
                },
            },
        })
    end)
end

return M
