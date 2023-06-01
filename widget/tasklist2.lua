local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local bling = require('bling')
local beautiful = require('beautiful')


local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then -- not working now.
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                { raise = true }
            )
        end
    end),
    awful.button({}, 2, function(c)
        c:kill()
    end),
    awful.button({}, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end))



bling.widget.task_preview.enable {
    x = 20,                    -- The x-coord of the popup
    y = 20,                    -- The y-coord of the popup
    height = 400,              -- The height of the popup
    width = 400,               -- The width of the popup
    placement_fn = function(c) -- Place the widget using awful.placement (this overrides x & y)
        awful.placement.bottom(c, {
            margins = {
                bottom = 30
            }
        })
    end,
    -- Your widget will automatically conform to the given size due to a constraint container.
    widget_structure = {
        {
            {
                {
                    id = 'icon_role',
                    widget = awful.widget.clienticon, -- The client icon
                },
                {
                    id = 'name_role', -- The client name / title
                    widget = wibox.widget.textbox,
                },
                layout = wibox.layout.flex.horizontal
            },
            widget = wibox.container.margin,
            margins = 5
        },
        {
            id = 'image_role', -- The client preview
            resize = true,
            valign = 'center',
            halign = 'center',
            widget = wibox.widget.imagebox,
        },
        layout = wibox.layout.fixed.vertical
    }
}

return function(s)
    return awful.widget.tasklist {
        screen          = s,
        filter          = awful.widget.tasklist.filter.allscreen,
        buttons         = tasklist_buttons,
        layout          = {
            spacing_widget = {
                {
                    forced_width  = 24,
                    forced_height = 24,
                    thickness     = 1,
                    color         = '#777777',
                    widget        = wibox.widget.separator
                },
                valign = 'center',
                halign = 'center',
                widget = wibox.container.place,
            },
            spacing        = 1,
            layout         = wibox.layout.fixed.horizontal
        },
        -- Notice that there is *NO* wibox.wibox prefix, it is a template,
        -- not a widget instance.
        widget_template = {
            {
                wibox.widget.base.make_widget(),
                -- forced_height = 5,
                forced_height = 3,
                id            = 'background_role',
                widget        = wibox.container.background,
            },
            {
                {
                    id     = 'clienticon',
                    widget = awful.widget.clienticon,
                },
                margins = 5,
                widget  = wibox.container.margin
            },
            nil,
            create_callback = function(self, c, index, objects) --luacheck: no unused args
                self:get_children_by_id('clienticon')[1].client = c

                -- BLING: Toggle the popup on hover and disable it off hover
                self:connect_signal('mouse::enter', function()
                    awesome.emit_signal("bling::task_preview::visibility", s,
                        true, c)
                end)
                self:connect_signal('mouse::leave', function()
                    awesome.emit_signal("bling::task_preview::visibility", s,
                        false, c)
                end)
            end,
            layout = wibox.layout.align.vertical,
        },
    }
end
