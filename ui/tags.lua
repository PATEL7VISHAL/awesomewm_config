local awful = require("awful")
local workspaces = require("config.tags")

local M = {
    workspaces = workspaces,
}

local function is_maximized_layout(layout)
    return layout == awful.layout.suit.max
        or layout == awful.layout.suit.max.fullscreen
end

local function sync_gap(t)
    t.gap = is_maximized_layout(t.layout) and 0 or 4
end

function M.create_for_screen(s)
    for index, workspace in ipairs(workspaces) do
        local t = awful.tag.add(tostring(index), {
            icon = workspace.icon,
            icon_only = true,
            layout = workspace.layout,
            gap = 4,
            gap_single_client = false,
            screen = s,
            selected = index == 1,
            workspace_type = workspace.type,
            default_app = workspace.default_app,
        })

        sync_gap(t)
    end
end

local function mark_activity(t)
    if t and not t.selected and not t.activity then
        t.activity = true
    end
end

function M.mark_client_activity(c)
    if not c then
        return
    end

    for _, t in ipairs(c:tags()) do
        mark_activity(t)
    end
end

function M.setup()
    tag.connect_signal("property::layout", sync_gap)

    client.connect_signal("property::name", function(c)
        if client.focus ~= c and not c.minimized then
            for _, t in ipairs(c:tags()) do
                mark_activity(t)
            end
        end
    end)

    client.connect_signal("tagged", function(c, t)
        if not t.selected and client.focus ~= c then
            mark_activity(t)
        end
    end)

    tag.connect_signal("property::selected", function(t)
        if t.selected and t.activity then
            t.activity = false
        end
    end)
end

return M
