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

function M.setup()
    tag.connect_signal("property::layout", sync_gap)
end

return M
