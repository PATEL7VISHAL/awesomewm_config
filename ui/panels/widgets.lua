local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")
local dpi = require("beautiful.xresources").apply_dpi

local M = {}

local function tag_buttons(modkey)
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

local function ordered_clients(s)
    local clients = {}
    for _, c in ipairs(client.get()) do
        if c.screen == s and not c.skip_taskbar then
            table.insert(clients, c)
        end
    end

    table.sort(clients, function(a, b)
        local a_tag = a.first_tag
        local b_tag = b.first_tag
        local a_index = a_tag and a_tag.index or math.huge
        local b_index = b_tag and b_tag.index or math.huge

        if a_index == b_index then
            return (a.window or 0) < (b.window or 0)
        end

        return a_index < b_index
    end)

    return clients
end

local function activate_task(c)
    if not c or not c.valid then
        return
    end

    local t = c.first_tag
    if t then
        t:view_only()
    end

    c.minimized = false
    c:activate({ context = "tasklist", raise = true })
end

local function focus_relative_task(s, offset)
    local clients = ordered_clients(s)
    if #clients == 0 then
        return
    end

    local current = client.focus
    for index, candidate in ipairs(clients) do
        if candidate == current then
            local target = clients[((index - 1 + offset) % #clients) + 1]
            activate_task(target)
            return
        end
    end

    activate_task(clients[1])
end

local function task_buttons()
    return {
        awful.button({}, 1, function(c)
            activate_task(c)
        end),
        awful.button({}, 2, function(c) c:kill() end),
        awful.button({}, 3, function()
            awful.menu.client_list({ theme = { width = dpi(260) } })
        end),
        awful.button({}, 4, function(c) focus_relative_task(c.screen, -1) end),
        awful.button({}, 5, function(c) focus_relative_task(c.screen, 1) end),
    }
end

local function workspace_colors()
    return {
        selected = beautiful.panel_accent or beautiful.border_color_active or "#7DD3FC",
        occupied = beautiful.panel_occupied or beautiful.fg_normal or "#A7C7D9",
        empty = beautiful.panel_inactive or beautiful.bg_focus or "#334155",
        urgent = beautiful.panel_urgent or beautiful.border_color_urgent or "#FB7185",
    }
end

local function pill_template()
    local colors = workspace_colors()
    local function update(self, t)
        self.bg = t.urgent and colors.urgent
            or t.activity and colors.urgent
            or t.selected and colors.selected
            or #t:clients() > 0 and colors.occupied
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

local function indicator_template()
    local colors = workspace_colors()
    local function update(self, t)
        local indicator = self:get_children_by_id("indicator")[1]
        local occupied = #t:clients() > 0

        indicator.bg = (t.urgent or t.activity) and colors.urgent
            or t.selected and colors.selected
            or occupied and colors.occupied
            or colors.empty
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

function M.taglist(s, opts)
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
        buttons = tag_buttons(opts.modkey),
        layout = {
            spacing = opts.spacing,
            layout = wibox.layout.fixed.horizontal,
        },
        widget_template = template,
    })

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

function M.tasklist(s, opts)
    local tasklist = awful.widget.tasklist({
        screen = s,
        filter = awful.widget.tasklist.filter.allscreen,
        source = function(task_screen)
            return ordered_clients(task_screen)
        end,
        buttons = task_buttons(),
        disable_task_name = true,
        base_layout = {
            spacing = opts.spacing,
            layout = wibox.layout.fixed.horizontal,
        },
        widget_template = {
            {
                {
                    {
                        id = "icon_role",
                        resize = true,
                        widget = wibox.widget.imagebox,
                    },
                    forced_height = dpi(22),
                    forced_width = dpi(22),
                    widget = wibox.container.place,
                },
                margins = dpi(4),
                widget = wibox.container.margin,
            },
            id = "background_role",
            forced_height = dpi(30),
            forced_width = dpi(30),
            shape = gears.shape.rounded_bar,
            widget = wibox.container.background,
            create_callback = function(self, c)
                self._task_client = c
                self._task_tooltip = awful.tooltip({
                    objects = { self },
                    mode = "outside",
                    preferred_positions = opts.position == "bottom" and { "top" } or { "bottom" },
                    timer_function = function()
                        local task_client = self._task_client
                        return task_client and task_client.valid
                            and (task_client.name or task_client.class or "Window")
                            or ""
                    end,
                })
            end,
            update_callback = function(self, c)
                self._task_client = c
            end,
        },
    })

    s.mytasklist = tasklist
    return tasklist
end

function M.layoutbox(s)
    local buttons = {
        awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end),
        awful.button({}, 4, function() awful.layout.inc(-1) end),
        awful.button({}, 5, function() awful.layout.inc(1) end),
    }

    s.mylayoutbox = awful.widget.layoutbox({
        screen = s,
        buttons = buttons,
    })

    return s.mylayoutbox
end

function M.clock(format)
    return wibox.widget({
        align = "center",
        valign = "center",
        format = format,
        widget = wibox.widget.textclock,
    })
end

return M
