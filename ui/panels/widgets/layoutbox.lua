local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local function buttons()
	return {
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(1)
		end),
	}
end

return function(s, opts)
	s.mylayoutbox = {

		awful.widget.layoutbox({
			screen = s,
			buttons = buttons(),
		}),

		top = opts.maring,
		bottom = opts.maring,
		left = opts.spacing,
		right = opts.spacing,
		widget = wibox.container.margin,
	}

	-- s.mylayoutbox = awful.widget.layoutbox({
	-- 	screen = s,
	-- 	buttons = buttons(),
	-- })

	return s.mylayoutbox
end
