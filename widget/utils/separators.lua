local wibox = require('wibox')
local awful = require('awful')
local gears = require('gears')

local dot   = function(s, opt)
    local _margin = opt.margin or 5
    local _color = '#009aba'
    local _width = 5

    local width = opt.width or _width
    local color = opt.color or _color
    local shape = opt.shape or gears.shape.circle

    local top = opt.top or _margin
    local bottom = opt.bottom or _margin
    local left = opt.left or _margin
    local right = opt.right or _margin


    return {
        {
            forced_width = width,
            color        = color,
            shape        = shape,
            widget       = wibox.widget.separator
        },
        top = top,
        bottom = bottom,
        left = left,
        right = right,
        layout = wibox.container.margin
    }
end

return {
    dot = dot,
}
