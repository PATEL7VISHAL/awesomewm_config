local awful = require("awful")
local naughty = require("naughty")
local ruled = require("ruled")

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

function M.setup()
    ruled.notification.connect_signal("request::rules", function()
        ruled.notification.append_rule({
            rule = {},
            properties = {
                screen = awful.screen.preferred,
                implicit_timeout = 5,
            },
        })
    end)

    naughty.connect_signal("request::display", function(n)
        local c = notification_client(n)
        if c and c ~= client.focus then
            require("ui.tags").mark_client_activity(c)
        end

        naughty.layout.box({ notification = n })
    end)
end

return M
