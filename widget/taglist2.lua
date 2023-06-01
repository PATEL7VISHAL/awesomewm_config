local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local bling = require('bling')
local beautiful = require('beautiful')

return function(s)
    bling.widget.tag_preview.enable {
        show_client_content = false, -- Whether or not to show the client content
        x = 10,                  -- The x-coord of the popup
        y = 10,                  -- The y-coord of the popup
        scale = 0.25,            -- The scale of the previews compared to the screen
        honor_padding = false,   -- Honor padding when creating widget size
        honor_workarea = false,  -- Honor work area when creating widget size
        placement_fn = function(c) -- Place the widget using awful.placement (this overrides x & y)
            awful.placement.top_left(c, {
                margins = {
                    top = 30,
                    left = 30
                }
            })
        end,
        background_widget = wibox.widget { -- Set a background image (like a wallpaper) for the widget
            image                 = beautiful.wallpaper,
            horizontal_fit_policy = "fit",
            vertical_fit_policy   = "fit",
            widget                = wibox.widget.imagebox
        }
    }

    return awful.widget.taglist {
        screen          = s,
        filter          = awful.widget.taglist.filter.all,
        style           = {
            shape = gears.shape.powerline
        },
        layout          = {
            spacing        = -12,
            spacing_widget = {
                color  = '#dddddd',
                shape  = gears.shape.powerline,
                widget = wibox.widget.separator,
            },
            layout         = wibox.layout.fixed.horizontal
        },
        widget_template = {
            {
                {
                    {
                        {
                            {
                                id     = 'index_role',
                                widget = wibox.widget.textbox,
                            },
                            margins = 4,
                            widget  = wibox.container.margin,
                        },
                        bg     = '#dddddd',
                        shape  = gears.shape.circle,
                        widget = wibox.container.background,
                    },
                    {
                        {
                            id     = 'icon_role',
                            widget = wibox.widget.imagebox,
                        },
                        margins = 2,
                        widget  = wibox.container.margin,
                    },
                    {
                        id     = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                left   = 18,
                right  = 18,
                widget = wibox.container.margin
            },
            id              = 'background_role',
            widget          = wibox.container.background,
            -- Add support for hover colors and an index label
            create_callback = function(self, c3, index, objects) --luacheck: no unused args
                self:get_children_by_id('index_role')[1].markup = '<b> ' .. index .. ' </b>'
                self:connect_signal('mouse::enter', function()
                    -- BLING: Only show widget when there are clients in the tag
                    if #c3:clients() > 0 then
                        -- BLING: Update the widget with the new tag
                        awesome.emit_signal("bling::tag_preview::update", c3)
                        -- BLING: Show the widget
                        awesome.emit_signal("bling::tag_preview::visibility", s, true)
                    end

                    if self.bg ~= '#ff0000' then
                        self.backup     = self.bg
                        self.has_backup = true
                    end
                    self.bg = '#ff0000'
                end)
                self:connect_signal('mouse::leave', function()
                    -- BLING: Turn the widget off
                    awesome.emit_signal("bling::tag_preview::visibility", s, false)

                    if self.has_backup then self.bg = self.backup end
                end)
            end,
            update_callback = function(self, c3, index, objects) --luacheck: no unused args
                self:get_children_by_id('index_role')[1].markup = '<b> ' .. index .. ' </b>'
            end,
        },
        buttons         = taglist_buttons
    }
end
