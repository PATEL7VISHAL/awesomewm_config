local wibox = require('wibox')

return {
    wibox.widget.systray(),
    top = 2,
    bottom = 2,
    layout = wibox.layout.margin,
}
