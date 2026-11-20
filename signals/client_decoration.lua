local awful = require("awful")
local gears = require("gears")
local windows = require("config.windows")

local M = {}

local function uses_maximized_layout(c)
    local t = c.first_tag
    local layout = t and t.layout

    return layout == awful.layout.suit.max
        or layout == awful.layout.suit.max.fullscreen
end

local function is_popup(c)
    local client_type = c.type
    local role = (c.role or ""):lower()

    return c.transient_for ~= nil
        or client_type == "dialog"
        or client_type == "utility"
        or client_type == "splash"
        or client_type == "toolbar"
        or client_type == "menu"
        or client_type == "dropdown_menu"
        or client_type == "popup_menu"
        or client_type == "tooltip"
        or client_type == "notification"
        or role:find("pop-up", 1, true) ~= nil
        or role:find("popup", 1, true) ~= nil
        or role:find("menu", 1, true) ~= nil
        or role:find("dialog", 1, true) ~= nil
end

local function rounded_shape(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, windows.client_corner_radius)
end

local function is_only_visible_client(c)
    local s = c.screen
    if not s then
        return false
    end

    local visible_count = 0
    local found = false

    for _, candidate in ipairs(s.clients) do
        if not candidate.hidden
            and not candidate.minimized
            and not candidate.skip_taskbar
            and candidate:isvisible()
        then
            visible_count = visible_count + 1
            found = found or candidate == c

            if visible_count > 1 then
                return false
            end
        end
    end

    return visible_count == 1 and found
end

local pending = {}
local flush_queued = false

local function apply(c)
    if not c.valid then
        return
    end

    local fullscreen = c.fullscreen
        or c.maximized
        or c.maximized_horizontal
        or c.maximized_vertical
        or uses_maximized_layout(c)
    local undecorated = fullscreen or is_popup(c) or is_only_visible_client(c)

    -- Any c.shape (even a rectangle) makes Awesome render a window-sized mask
    -- on every resize; undecorated windows need none, so clear it instead.
    local rounded = not undecorated
    if c._decoration_rounded ~= rounded then
        c._decoration_rounded = rounded
        c.shape = rounded and rounded_shape or nil
    end

    local border_width = undecorated and 0 or windows.client_border_width
    if c.border_width ~= border_width then
        c.border_width = border_width
    end

    local border_color = c.active
        and windows.client_border_color
        or windows.client_border_color_inactive
    if c.border_color ~= border_color then
        c.border_color = border_color
    end
end

local function flush()
    flush_queued = false
    local batch = pending
    pending = {}

    for c in pairs(batch) do
        apply(c)
    end
end

-- Coalesce bursts of signals (manage + tagged + layout...) into one pass.
local function update(c)
    if not c.valid then
        return
    end

    pending[c] = true

    if not flush_queued then
        flush_queued = true
        gears.timer.delayed_call(flush)
    end
end

local function update_screen_clients(s)
    for _, c in ipairs(s.clients) do
        update(c)
    end
end

function M.setup()
    client.connect_signal("request::border", apply)
    client.connect_signal("request::manage", update)
    client.connect_signal("property::role", update)
    client.connect_signal("property::type", update)
    client.connect_signal("property::minimized", update)
    client.connect_signal("property::fullscreen", update)
    client.connect_signal("property::maximized", update)
    client.connect_signal("tagged", update)
    client.connect_signal("untagged", update)
    client.connect_signal("request::unmanage", function(c)
        pending[c] = nil
        if c.screen then
            local s = c.screen
            gears.timer.delayed_call(function()
                if s.valid then
                    update_screen_clients(s)
                end
            end)
        end
    end)

    tag.connect_signal("property::layout", function(t)
        for _, c in ipairs(t:clients()) do
            update(c)
        end
    end)
    tag.connect_signal("property::selected", function(t)
        if t.screen then
            update_screen_clients(t.screen)
        end
    end)
end

return M
