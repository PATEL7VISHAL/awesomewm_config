local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local M = {}

function M.new(child, config)
	config = config or {}

	local widget = wibox.container.background(child)

	widget.shape = config.shape or gears.shape.circle

	widget.bg = config.background or "#00000000"
	widget.border_width = config.border_width or 1
	widget.border_color = config.border_color or "#ffffff30"

	if config.width then
		widget.forced_width = config.width
	end

	if config.height then
		widget.forced_height = config.height
	end

	widget:connect_signal("mouse::enter", function()
		widget.bg = config.hover_background or widget.bg
		widget.border_color = config.hover_border or widget.border_color
	end)

	widget:connect_signal("mouse::leave", function()
		widget.bg = config.background or "#00000000"
		widget.border_color = config.border_color or "#ffffff30"
	end)

	if config.on_click then
		widget:buttons(gears.table.join(awful.button({}, 1, config.on_click)))
	end

	return widget
end

return M
