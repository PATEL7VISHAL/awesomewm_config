local awful = require('awful')
local gears = require('gears')
local client = require('awful.client')
local wibox = require('wibox')
local log = require('module.log')
-- Create a wibox for each screen and add it

local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        -- if client.focus then
        -- client.focus:move_to_tag(t)
        -- end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        -- if client.focus then
        -- client.focus:toggle_tag(t)
        -- end
    end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)



function load_tag(self, t, index, tags)
    -- log(t)
    -- log(t.icon)
    -- log(t.text)
    -- log(self)
    local icon = t.icon
    local tagicon_widget = self:get_children_by_id('icon_role')[1]
    local tagtext_widget = self:get_children_by_id('text_role')[1]

    local text = tagtext_widget.text;
    -- self:get_children_by_id('text_role')[1]:set_markup()

    local tmp = {
        text = "hello",
        wibox.widget.textbox,
    }

    local icon_widget = {
        image = icon,
        forced_height = 24,
        forced_width = 24,
        clip_shape = gears.shape.rounded_rect,
        -- resize = 0
        widget = wibox.widget.imagebox,
    }
end

return function(s)
    return awful.widget.taglist {
        screen          = s,
        filter          = awful.widget.taglist.filter.all,
        buttons         = taglist_buttons,
        widget_template = {
            {
                {
                    id     = 'icon_role',
                    widget = wibox.widget.imagebox,
                },
                margins = 0,
                widget  = wibox.container.margin,
            },
            {
                id     = 'text_role',
                widget = wibox.widget.textbox,
            },
            spacing = 10,
            layout = wibox.layout.fixed.horizontal,

            create_callback = load_tag,
            update_callback = load_tag
        },
        style           = {
            font = 'Ubuntu Nono Bold 14'
        }
    }
end
