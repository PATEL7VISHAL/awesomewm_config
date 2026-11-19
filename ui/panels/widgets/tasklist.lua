local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local dpi = require("beautiful.xresources").apply_dpi

-- Stable workspace-first ordering makes the task icons match the workspace strip.
local function ordered_clients(s)
    local clients = {}
    for _, c in ipairs(client.get()) do
        if c.screen == s and not c.skip_taskbar then
            table.insert(clients, c)
        end
    end

    table.sort(clients, function(a, b)
        local a_index = a.first_tag and a.first_tag.index or math.huge
        local b_index = b.first_tag and b.first_tag.index or math.huge

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

    for index, candidate in ipairs(clients) do
        if candidate == client.focus then
            activate_task(clients[((index - 1 + offset) % #clients) + 1])
            return
        end
    end

    activate_task(clients[1])
end

local function buttons()
    return {
        awful.button({}, 1, activate_task),
        awful.button({}, 2, function(c) c:kill() end),
        awful.button({}, 3, function()
            awful.menu.client_list({ theme = { width = dpi(260) } })
        end),
        awful.button({}, 4, function(c) focus_relative_task(c.screen, -1) end),
        awful.button({}, 5, function(c) focus_relative_task(c.screen, 1) end),
    }
end

return function(s, opts)
    local tasklist = awful.widget.tasklist({
        screen = s,
        filter = awful.widget.tasklist.filter.allscreen,
        source = function(task_screen)
            return ordered_clients(task_screen)
        end,
        buttons = buttons(),
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
