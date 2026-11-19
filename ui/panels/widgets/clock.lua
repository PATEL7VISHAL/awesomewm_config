local wibox = require("wibox")

return function(format)
    return wibox.widget({
        align = "center",
        valign = "center",
        format = format,
        widget = wibox.widget.textclock,
    })
end
