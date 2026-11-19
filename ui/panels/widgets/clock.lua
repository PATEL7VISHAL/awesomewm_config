local wibox = require("wibox")
local beautiful = require("beautiful")

return function(format)
	return wibox.widget({
		align = "center",
		valign = "center",
		format = format,
		font = beautiful.widget_fonts.clock.string,
		widget = wibox.widget.textclock,
	})
end
