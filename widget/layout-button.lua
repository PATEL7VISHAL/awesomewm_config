local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')

return function(s)
    local mylayoutbox =
    {
        awful.widget.layoutbox(s),
        -- top = 3,
        -- bottom = 3,
        -- left = 3,
        -- right = 3,
        margins = 3,
        layout = wibox.layout.margin
    }

    -- mylayoutbox:buttons(
    --     gears.table.join(
    --         awful.button({}, 1, function() awful.layout.inc(1) end),
    --         awful.button({}, 3, function() awful.layout.inc( -1) end),
    --         awful.button({}, 4, function() awful.layout.inc(1) end),
    --         awful.button({}, 5, function() awful.layout.inc( -1) end)
    --     )
    -- )

    return mylayoutbox
end
