local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")
local dpi = require("beautiful.xresources").apply_dpi

local function buttons(modkey)
    return {
        awful.button({}, 1, function(t) t:view_only() end),
        awful.button({ modkey }, 1, function(t)
            if client.focus then
                client.focus:move_to_tag(t)
            end
        end),
        awful.button({}, 3, awful.tag.viewtoggle),
        awful.button({ modkey }, 3, function(t)
            if client.focus then
                client.focus:toggle_tag(t)
            end
        end),
        awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
        awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end),
    }
end

local function colors()
    local indicator = beautiful.panel_indicator or {}

    return {
        selected = indicator.selected or beautiful.panel_accent or beautiful.border_color_active or "#7DD3FC",
        occupied = indicator.occupied or beautiful.panel_occupied or beautiful.fg_normal or "#A7C7D9",
        empty = indicator.empty or beautiful.panel_inactive or beautiful.bg_focus or "#334155",
        urgent = indicator.urgent or beautiful.panel_urgent or beautiful.border_color_urgent or "#FB7185",
    }
end

-- Rounded icon pills use fill/background state to keep the icon artwork unchanged.
local function pill_template()
    local palette = colors()

    local function update(self, t)
        self.bg = (t.urgent or t.activity) and palette.urgent
            or t.selected and palette.selected
            or #t:clients() > 0 and palette.occupied
            or gears.color.transparent
        self.opacity = (t.selected or #t:clients() > 0 or t.urgent or t.activity) and 1 or 0.45
    end

    return {
        {
            {
                id = "icon_role",
                resize = true,
                widget = wibox.widget.imagebox,
            },
            forced_height = dpi(20),
            forced_width = dpi(20),
            widget = wibox.container.place,
        },
        id = "background_role",
        margins = dpi(5),
        shape = gears.shape.rounded_bar,
        widget = wibox.container.background,
        create_callback = update,
        update_callback = update,
    }
end

-- The indicator's variable height communicates empty/occupied/selected/urgent states.
local function indicator_template()
    local palette = colors()

    local function update(self, t)
        local indicator = self:get_children_by_id("indicator")[1]
        local occupied = #t:clients() > 0

        indicator.bg = (t.urgent or t.activity) and palette.urgent
            or t.selected and palette.selected
            or occupied and palette.occupied
            or palette.empty
        indicator.forced_height = (t.urgent or t.activity) and dpi(24)
            or t.selected and dpi(24)
            or occupied and dpi(14)
            or dpi(5)
        self.opacity = (t.selected or occupied or t.urgent or t.activity) and 1 or 0.55
    end

    return {
        {
            {
                {
                    {
                        id = "indicator",
                        forced_width = dpi(3),
                        shape = gears.shape.rounded_bar,
                        widget = wibox.container.background,
                    },
                    widget = wibox.container.place,
                },
                {
                    {
                        id = "icon_role",
                        resize = true,
                        widget = wibox.widget.imagebox,
                    },
                    forced_height = dpi(24),
                    forced_width = dpi(24),
                    widget = wibox.container.place,
                },
                spacing = dpi(4),
                layout = wibox.layout.fixed.horizontal,
            },
            left = dpi(2),
            right = dpi(2),
            widget = wibox.container.margin,
        },
        forced_height = dpi(28),
        widget = wibox.container.place,
        create_callback = update,
        update_callback = update,
    }
end

return function(s, opts)
    local style = os.getenv("AWESOME_WORKSPACE_STYLE") or opts.style or "indicator"
    local template

    if style == "pill" then
        template = pill_template()
    elseif style == "indicator" then
        template = indicator_template()
    else
        gears.debug.print_error("Unknown workspace widget style '" .. tostring(style) .. "'; using indicator")
        template = indicator_template()
    end

    local taglist = awful.widget.taglist({
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = buttons(opts.modkey),
        layout = {
            spacing = opts.spacing,
            layout = wibox.layout.fixed.horizontal,
        },
        widget_template = template,
    })

    -- Custom activity is not an internal taglist signal, so explicitly redraw it.
    for _, t in ipairs(s.tags) do
        t:connect_signal("property::activity", function()
            taglist._do_taglist_update()
        end)
    end

    return {
        taglist,
        left = opts.margin,
        right = opts.margin,
        widget = wibox.container.margin,
    }
end
