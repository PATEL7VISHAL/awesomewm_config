local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local config = require("config.ram")
local ram = require("core.ram")

local M = {}

local function parse_color(color)
	color = color:gsub("#", "")

	return tonumber(color:sub(1, 2), 16) / 255, tonumber(color:sub(3, 4), 16) / 255, tonumber(color:sub(5, 6), 16) / 255
end

local function set_color(cr, color, alpha)
	local r, g, b = parse_color(color)

	cr:set_source_rgba(r, g, b, alpha or 1)
end

local function create_ring()
	local ring = wibox.widget.base.make_widget()

	local appearance = config.appearance

	ring.draw = function(_, _, cr, width, height)
		local size = math.min(width, height)

		local thickness = appearance.thickness or 4
		local radius = math.max(0, (size - thickness) / 2)

		local center_x = width / 2
		local center_y = height / 2

		local usage = ram.get_state().usage or 0

		local progress_color = appearance.progress_color or "#ffffff"
		local track_color = appearance.track_color or "#ffffff"

		cr:save()

		cr:set_line_width(thickness)
		cr:set_line_cap(1)

		-- Background track.
		set_color(cr, track_color, appearance.track_opacity or 0.18)

		cr:arc(center_x, center_y, radius, 0, math.pi * 2)

		cr:stroke()

		-- Usage progress.
		if usage > 0 then
			local start_angle = -math.pi / 2
			local end_angle = start_angle + (math.pi * 2 * usage / 100)

			set_color(cr, progress_color)

			cr:arc(center_x, center_y, radius, start_angle, end_angle)

			cr:stroke()
		end

		cr:restore()
	end

	ring.fit = function(_, _, width, height)
		local fixed_size = appearance.size

		if fixed_size then
			return fixed_size, fixed_size
		end

		-- Use the available panel height.
		local size = math.min(width, height)

		return size, size
	end

	return ring
end

local function format_memory(kb)
	if kb >= 1024 * 1024 then
		return string.format("%.2f GB", kb / (1024 * 1024))
	end

	return string.format("%.0f MB", kb / 1024)
end

local function create()
	local state = ram.get_state()
	local appearance = config.appearance

	local ring = create_ring()
	local percentage = wibox.widget.textbox()

	percentage.align = "center"
	percentage.valign = "center"

	local font_family = appearance.font_family or "Ubuntu Mono"
	local font_size = appearance.font_size or 11
	local font_weight = appearance.font_weight or "bold"

	local layout = wibox.layout.stack()

	layout:add(ring)
	layout:add(wibox.container.place(percentage))

	local widget = wibox.container.background(layout)

	local processes = state.processes or {}

	local function update_percentage(usage)
		local text_color = appearance.text_color or "#ffffff"

		percentage:set_markup(
			string.format(
				'<span foreground="%s" font_family="%s" font_weight="%s" size="%dpt">%d</span>',
				text_color,
				font_family,
				font_weight,
				font_size,
				math.floor(usage + 0.5)
			)
		)

		ring:emit_signal("widget::redraw_needed")
	end

	local function update_tooltip()
		local lines = {
			"Memory",
			"",
			string.format("Used: %s / %s", format_memory(state.used_kb), format_memory(state.total_kb)),
			string.format("Usage: %.1f%%", state.usage),
			string.format("Available: %s", format_memory(state.available_kb)),
			"",
			"Top processes:",
		}

		if #processes == 0 then
			lines[#lines + 1] = "  No process data"
		end

		for i, process in ipairs(processes) do
			local percentage_of_total = state.total_kb > 0 and (process.rss_kb / state.total_kb) * 100 or 0

			lines[#lines + 1] = string.format(
				"  %d. %s  %s (%.1f%%)",
				i,
				process.name,
				format_memory(process.rss_kb),
				percentage_of_total
			)
		end

		lines[#lines + 1] = ""
		lines[#lines + 1] = "Process memory: RSS"

		return table.concat(lines, "\n")
	end

	if (config.tooltip or {}).enabled then
		awful.tooltip({
			objects = { widget },
			timer_function = update_tooltip,
			preferred_positions = { "top", "bottom" },
			margin_leftright = 8,
			margin_topbottom = 6,
		})
	end

	awesome.connect_signal("ram::update", function(data)
		state = data

		update_percentage(data.usage)
	end)

	awesome.connect_signal("ram::processes", function(data)
		processes = data
	end)

	update_percentage(state.usage or 0)

	ram.start(config)

	return widget
end

M.new = create

return M
