local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")

local config = require("config.network")
local network = require("core.network")
local drawing = require("ui.panels.widgets.lib.drawing")

local M = {}

local apply_dpi = beautiful.xresources.apply_dpi

local appearance = config.appearance
local levels = appearance.levels or 10
local speed_units = {
	"B/s",
	"KB/s",
	"MB/s",
	"GB/s",
	"TB/s",
}

local function number_or_zero(value)
	return type(value) == "number" and value or 0
end

local function calculate_level(speed)
	speed = number_or_zero(speed)

	if speed <= 0 then
		return 0
	end

	local reference = math.max(1, config.reference_speed or 10485760)

	local intensity = math.log(1 + speed) / math.log(1 + reference)

	intensity = math.max(0, math.min(1, intensity))

	return math.min(levels, math.floor(intensity * levels + 0.5))
end

local function format_speed(speed)
	local value = number_or_zero(speed)
	local unit_index = 1

	while value >= 1024 and unit_index < #speed_units do
		value = value / 1024
		unit_index = unit_index + 1
	end

	if value >= 100 then
		return string.format("%.0f %s", value, speed_units[unit_index])
	end

	return string.format("%.1f %s", value, speed_units[unit_index])
end

local function create_meter(color, width, height)
	local meter = wibox.widget.base.make_widget()

	local current_level = 0

	meter.set_level = function(_, level)
		level = math.max(0, math.min(levels, number_or_zero(level)))

		if current_level == level then
			return
		end

		current_level = level

		meter:emit_signal("widget::redraw_needed")
	end

	meter.draw = function(_, _, cr, draw_width, draw_height)
		cr:save()

		local radius = math.min(apply_dpi(appearance.radius or 3), draw_width / 2, draw_height / 2)

		-- Background track.
		cr:set_source(gears.color(config.colors.track))

		drawing.rounded_rectangle(cr, 0, 0, draw_width, draw_height, radius)

		cr:fill()

		-- Filled portion.
		if current_level > 0 then
			local fill_height = math.max(1, math.floor(draw_height * current_level / levels + 0.5))

			local y = draw_height - fill_height

			cr:set_source(gears.color(color))

			drawing.rounded_rectangle(cr, 0, y, draw_width, fill_height, radius)

			cr:fill()
		end

		cr:restore()
	end

	meter.fit = function()
		return width, height
	end

	return meter
end

local function create(panel_height)
	local download_color = config.colors.download
	local upload_color = config.colors.upload

	local meter_height

	if appearance.height then
		meter_height = apply_dpi(appearance.height)
	else
		local ratio = appearance.height_ratio or 0.62

		meter_height = math.floor((panel_height or 32) * ratio)

		meter_height = math.max(
			apply_dpi(appearance.min_height or 18),
			math.min(meter_height, apply_dpi(appearance.max_height or 38))
		)
	end

	local meter_width = apply_dpi(appearance.bar_width or 9)

	local download_text = wibox.widget.textbox()
	local upload_text = wibox.widget.textbox()

	local font = beautiful.widget_fonts.network or beautiful.widget_fonts.cpu

	if font then
		download_text.font = font.string or font
		upload_text.font = font.string or font
	end

	-- Reserve the widest realistic text ("99.9 MB/s" + arrow) so the widget
	-- does not resize and shift its neighbours on every update.
	local probe = wibox.widget.textbox()
	probe.font = download_text.font
	probe:set_text(config.max_text or "99.9 MB/s ↓")

	local text_width = math.ceil(probe:get_preferred_size(awful.screen.focused()))

	download_text.forced_width = text_width
	download_text.align = "right"
	upload_text.forced_width = text_width
	upload_text.align = "left"

	local download_meter = create_meter(download_color, meter_width, meter_height)

	local upload_meter = create_meter(upload_color, meter_width, meter_height)

	local layout = wibox.layout.fixed.horizontal()

	layout.spacing = apply_dpi(appearance.spacing or 3)

	-- Download speed + arrow.
	layout:add(download_text)

	-- Exactly two vertical meters.
	layout:add(download_meter)
	layout:add(upload_meter)

	-- Arrow + upload speed.
	layout:add(upload_text)

	local widget = wibox.container.background(layout)

	local last_download_markup
	local last_upload_markup

	local current_download = number_or_zero(network.get_state().download)
	local current_upload = number_or_zero(network.get_state().upload)
	local current_interface = network.get_state().interface

	local function update_text(speed, color, arrow, textbox, previous)
		local markup = string.format('<span foreground="%s">%s %s</span>', color, speed, arrow)

		if markup ~= previous then
			textbox:set_markup(markup)
			return markup
		end

		return previous
	end

	local function update(data)
		if type(data) ~= "table" then
			return
		end

		current_download = number_or_zero(data.download)
		current_upload = number_or_zero(data.upload)
		current_interface = type(data.interface) == "string" and data.interface or nil

		last_download_markup =
			update_text(format_speed(current_download), download_color, "↓", download_text, last_download_markup)

		last_upload_markup =
			update_text("↑ " .. format_speed(current_upload), upload_color, "", upload_text, last_upload_markup)

		download_meter:set_level(calculate_level(current_download))

		upload_meter:set_level(calculate_level(current_upload))
	end

	awesome.connect_signal("network::update", update)
	network.start(config)
	update(network.get_state())

	if (config.tooltip or {}).enabled then
		awful.tooltip({
			objects = { widget },

			timer_function = function()
				return table.concat({
					"Network",
					"",
					"Interface: " .. (current_interface or "Disconnected"),
					"Download: " .. format_speed(current_download),
					"Upload: " .. format_speed(current_upload),
				}, "\n")
			end,

			preferred_positions = { "top", "bottom" },
			margin_leftright = apply_dpi(8),
			margin_topbottom = apply_dpi(6),
		})
	end

	return widget
end

M.new = create

return M
