local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")
local ruled = require("ruled")
local wibox = require("wibox")

local settings = require("config.notifications")

local M = {}

local function normalize(value)
    return (value or ""):lower():gsub("[^%w]+", "")
end

local function notification_client(n)
    local app_name = normalize(n.app_name or n.appname)
    if app_name == "" then
        return nil
    end

    for _, c in ipairs(client.get()) do
        local class = normalize(c.class)
        local instance = normalize(c.instance)
        local name = normalize(c.name)

        if class == app_name or instance == app_name
            or class:find(app_name, 1, true)
            or instance:find(app_name, 1, true)
            or name:find(app_name, 1, true)
        then
            return c
        end
    end
end

local function urgency_color(n)
    return beautiful["notification_accent_" .. (n.urgency or "normal")] or beautiful.notification_accent_normal
end

-- Urgency stripe; the color follows the notification urgency.
local function accent_bar()
    local bar = wibox.container.background()
    bar.forced_width = settings.accent_width

    rawset(bar, "set_notification", function(_, n)
        bar.bg = urgency_color(n)
    end)

    return bar
end

-- Text widget bound to a notification property. Plain textboxes keep this much
-- cheaper than the stock widgets and allow per-role styling.
local function text_widget(property, format)
    local tb = wibox.widget.textbox()
    tb.wrap = "word_char"
    tb.ellipsize = "end"

    rawset(tb, "set_notification", function(_, n)
        local function refresh()
            local text = n[property]
            tb.visible = text ~= nil and text ~= ""

            if not tb.visible then
                return
            end

            -- Bodies may contain markup; fall back to plain text if it is invalid.
            if not tb:set_markup_silently(format(text, n)) then
                tb:set_text(text)
            end
        end

        refresh()
        n:weak_connect_signal("property::" .. property, refresh)
        rawset(tb, "_refresh_" .. property, refresh)
    end)

    return tb
end

local function title_widget()
    return text_widget("title", function(text)
        return string.format("<b>%s</b>", gears.string.xml_escape(text))
    end)
end

local function message_widget()
    return text_widget("message", function(text)
        return string.format('<span foreground="%s">%s</span>', beautiful.notification_muted, text)
    end)
end

local function action_list()
    return naughty.list.actions({
        base_layout = wibox.widget({
            spacing = settings.spacing / 2,
            layout = wibox.layout.flex.horizontal,
        }),
        widget_template = {
            {
                {
                    id = "text_role",
                    align = "center",
                    widget = wibox.widget.textbox,
                },
                top = settings.spacing / 2,
                bottom = settings.spacing / 2,
                left = settings.spacing,
                right = settings.spacing,
                widget = wibox.container.margin,
            },
            bg = beautiful.panel_border,
            fg = beautiful.notification_fg,
            shape = gears.shape.rounded_rect,
            widget = wibox.container.background,
        },
    })
end

local function widget_template()
    return {
        {
            {
                { widget = accent_bar },
                {
                    {
                        {
                            {
                                { widget = naughty.widget.icon },
                                valign = "top",
                                widget = wibox.container.place,
                            },
                            {
                                { widget = title_widget },
                                { widget = message_widget },
                                spacing = settings.spacing / 2,
                                layout = wibox.layout.fixed.vertical,
                            },
                            fill_space = true,
                            spacing = settings.spacing,
                            layout = wibox.layout.fixed.horizontal,
                        },
                        action_list(),
                        spacing = settings.spacing,
                        layout = wibox.layout.fixed.vertical,
                    },
                    margins = settings.padding,
                    widget = wibox.container.margin,
                },
                fill_space = true,
                layout = wibox.layout.fixed.horizontal,
            },
            id = "background_role",
            widget = wibox.container.background,
        },
        strategy = "exact",
        width = settings.width,
        widget = wibox.container.constraint,
    }
end

function M.setup()
    ruled.notification.connect_signal("request::rules", function()
        ruled.notification.append_rule({
            rule = {},
            properties = {
                screen = awful.screen.preferred,
                implicit_timeout = settings.timeouts.normal,
                -- naughty's urgency presets would otherwise paint critical red.
                bg = beautiful.notification_bg,
                fg = beautiful.notification_fg,
                border_color = beautiful.notification_border_color,
            },
        })

        for _, urgency in ipairs({ "low", "critical" }) do
            ruled.notification.append_rule({
                rule = { urgency = urgency },
                properties = { implicit_timeout = settings.timeouts[urgency] },
            })
        end
    end)

    naughty.connect_signal("request::display", function(n)
        local c = notification_client(n)
        if c and c ~= client.focus then
            require("ui.tags").mark_client_activity(c)
        end

        naughty.layout.box({
            notification = n,
            widget_template = widget_template(),
        })
    end)
end

return M
