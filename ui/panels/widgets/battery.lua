local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi

local battery = require("core.battery")

local M = {}

local function battery_bar_shape(cr, width, height)
	gears.shape.rounded_rect(cr, width, height, dpi(7))
end

local function get_color(state)
	if state.charging then
		return beautiful.battery_charging
	end

	if state.percentage <= 15 then
		return beautiful.battery_critical
	end

	if state.percentage <= 30 then
		return beautiful.battery_warning
	end

	return beautiful.battery_normal
end

local function create()
	local percentage = wibox.widget.textbox()
	local charging_icon = wibox.widget.textbox()
	percentage.align = "center"
	percentage.valign = "center"
	percentage.font = beautiful.widget_fonts.battery.string

	local progressbar = wibox.widget({
		max_value = 100,
		value = 0,
		forced_width = dpi(38),
		forced_height = dpi(16),
		color = beautiful.battery_normal,
		background_color = beautiful.battery_empty,
		border_width = 0,
		shape = battery_bar_shape,
		bar_shape = battery_bar_shape,
		widget = wibox.widget.progressbar,
	})

	local bar = wibox.widget({
		progressbar,
		{
			percentage,
			halign = "center",
			valign = "center",
			widget = wibox.container.place,
		},
		layout = wibox.layout.stack,
	})

	local content = wibox.widget({
		{
			bar,
			charging_icon,
			spacing = dpi(5),
			layout = wibox.layout.fixed.horizontal,
		},
		forced_height = dpi(18),
		widget = wibox.container.background,
	})

	-- Keep the battery capsule compact and vertically centered in the panel.
	local widget = wibox.widget({
		content,
		top = dpi(5),
		bottom = dpi(5),
		widget = wibox.container.margin,
	})

	local current_state

	local function update(state)
		current_state = state
		local color = get_color(state)

		progressbar.value = state.percentage
		progressbar.color = color
		percentage:set_markup(
			string.format('<span foreground="%s">%d</span>', beautiful.battery_label_fg, state.percentage)
		)
		charging_icon:set_text(state.charging and "⚡" or "")
	end

	local function update_tooltip()
		if not current_state then
			return "Battery information unavailable"
		end

		local lines = {
			string.format("Battery: %d%%", current_state.percentage),
			"Status: " .. current_state.status,
			"Connected batteries: " .. current_state.battery_count,
		}

		for index, item in ipairs(current_state.batteries) do
			lines[#lines + 1] = string.format("Battery %d: %d%% (%s)", index, item.capacity, item.status or "Unknown")
		end

		return table.concat(lines, "\n")
	end

	awful.tooltip({
		objects = { widget },
		timer_function = update_tooltip,
		preferred_positions = { "top", "bottom" },
		margin_leftright = 8,
		margin_topbottom = 6,
	})

	awesome.connect_signal("battery::update", update)
	awesome.connect_signal("battery::unavailable", function()
		current_state = nil
		percentage:set_text("--")
		charging_icon:set_text("")
		progressbar.value = 0
	end)

	local initial_state = battery.get_state()
	if initial_state then
		update(initial_state)
	end

	battery.start()
	return widget
end

M.new = create

return M
