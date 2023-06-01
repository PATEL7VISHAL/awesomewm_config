local wibox = require('wibox')
local awful = require('awful')
local calendar_widget = require('widget.calender')
local naughty = require('naughty')
local mytextclock = wibox.widget.textclock('<span font="Ubuntu bold 11">  %I:%M:%S %p  %d-%m </span>', 1)
local client = require('awful.client')

local cw = calendar_widget({
    theme = 'monokai',
    placement = 'bottom_right',
    radius = 16,
})

mytextclock:connect_signal("button::press",
    -- function(client, lx, ly, button, mods, find_widgets_result)
    function(_, lx, _, button, _, find_widgets_result)
        local x = find_widgets_result.x;
        local width = find_widgets_result.width;
        local center_x = x + width;

        -- naughty.notify({
        --     preset = naughty.config.presets.critical,
        --     text = tostring(center_x)
        -- })

        if button == 1 then cw.toggle(center_x) end
    end)


return mytextclock;
