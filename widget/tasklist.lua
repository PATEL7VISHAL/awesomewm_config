local awful = require('awful')
local gears = require('gears')
local client = require('awful.client')
local wibox = require('wibox')
local beautiful = require('beautiful')
local separators = require('widget.utils.separators')
local log = require('module.log')
local separators = require('widget.utils.separators')

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
        awful.client.focus.byidx( -1)
    end))

local tasklist_only_icon = function(s)
    return awful.widget.tasklist {
        screen          = s,
        filter          = awful.widget.tasklist.filter.alltags,
        buttons         = tasklist_buttons,

        widget_template = {
            {
                {
                    id     = 'icon_role',
                    widget = wibox.widget.imagebox,
                },
                top    = 2,
                bottom = 2,
                left   = 5,
                right  = 5,
                widget = wibox.container.margin,

            },
            id     = 'background_role',
            widget = wibox.container.background,
        },

        style           = {
            -- fg_normal = "#77777700",
            bg_normal   = "#77777700",

            -- fg_focus  = "#77777784",
            -- bg_focus  = "#77777784",
            bg_focus    = "#aaaaaa77",

            -- fg_urgent = "#a8990066",
            bg_urgent   = "#b8890066",

            -- shape     = gears.shape,
            shape_focus = gears.shape.rounded_rect,

            -- shape_border_width           = 2,
            -- shape_border_color           = '#f70000',
            -- shape                        = gears.shape.rounded_bar,

            -- shape_border_width = 2,
            -- shape_border_color = "#777777",

            -- shape_focus = gears.shape.rounded_rect,
            -- shape_border_width_focus     = 2,
            -- shape_border_color_focus     = "#00aa00aa",

            -- shape_minimized = gears.shape.rounded_rect,
            -- shape_border_width_minimized = 2,
            -- shape_border_color_minimize  = "#66777777",

            -- -- shape_urgent = ,
            -- shape_border_width_urgent    = 2,
            -- shape_border_color_urgen     = "#a89900aa",

        }
    }
end


-- return tasklist2
--`objects` contains tasklist array --`self` contains tasklist
local function load_tasklist(self, c, index, objects)
    --* left to italic the class name
    local task_name = c.name;
    local task_label = c.name;

    local max_len = 25
    if task_name:len() > max_len then
        task_label = task_name:sub(0, max_len) .. "... | " .. c.class
    end

    c.name = task_label
end

local tasklist_with_title = function(s)
    local _tasklist = awful.widget.tasklist {
        screen          = s,
        filter          = awful.widget.tasklist.filter.focused,
        buttons         = tasklist_buttons,

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
            spacing = 5,
            layout = wibox.layout.fixed.horizontal,
            create_callback = load_tasklist,
            update_callback = load_tasklist,
        },
        style           = {
            -- font = 'Ubuntu 20',
            font_focus = 'Ubuntu bold 11'
        }
    }

    local _tasklist_t = awful.tooltip {}
    _tasklist_t:add_to_object(_tasklist)

    _tasklist:connect_signal('mouse::enter', function(c)
        -- _tasklist_t.text = os.date('Today is %A %B %d %Y\nThe time is %T')
        -- local a=  awful.client.property;
        
        -- log(client.focus)
    end)


    return _tasklist
end

return {
    icon_only = tasklist_only_icon,
    icon_with_title = tasklist_with_title,
}
