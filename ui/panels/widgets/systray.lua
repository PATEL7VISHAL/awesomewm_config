local wibox = require("wibox")
local beautiful = require("beautiful")

local config = require("config.systray")

local M = {}

local dpi = beautiful.xresources.apply_dpi

function M.new()
	if not config.enabled then
		return nil
	end

	-- Native systray styling.
	beautiful.systray_icon_spacing = dpi(config.spacing)

	local tray = wibox.widget.systray(config.reverse)

	tray:set_base_size(dpi(config.icon_size))
	tray:set_horizontal(config.horizontal)

	-- Keep the tray centered vertically.
	local aligned = wibox.container.place(tray, "center", "center", false, true)

	-- Outer spacing around the tray.
	local container = wibox.container.margin(
		aligned,
		dpi(config.margin.left),
		dpi(config.margin.right),
		dpi(config.margin.top),
		dpi(config.margin.bottom)
	)

	return container
end

return M
