local awful = require("awful")
local gtimer = require("gears.timer")

local M = {}

local function focus_selected_tag(t)
    if not t.selected or t.screen ~= awful.screen.focused() then
        return
    end

    gtimer.delayed_call(function()
        if not t.selected or t.screen ~= awful.screen.focused() then
            return
        end

        if client.focus and client.focus.first_tag == t and not client.focus.minimized then
            client.focus:raise()
            return
        end

        local c = awful.client.focus.history.get(t.screen, 0, function(candidate)
            return candidate.first_tag == t and not candidate.minimized
        end)

        if c then
            c:activate({ context = "tag_switch", raise = true })
        end
    end)
end

function M.setup()
    client.connect_signal("mouse::enter", function(c)
        c:activate({ context = "mouse_enter", raise = false })
    end)

    tag.connect_signal("property::selected", focus_selected_tag)
end

return M
