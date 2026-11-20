local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")

local config = require("config.cpu")
local cpu = require("core.cpu")
local drawing = require("ui.panels.widgets.lib.drawing")

local M = {}

local clamp = drawing.clamp
local set_color = drawing.set_color

local function get_color(usage)
	return drawing.color_at_threshold(usage, beautiful.widget_theme.cpu.colors or config.colors)
end

local function create_graph(history)
	local graph = wibox.widget.base.make_widget()

	local appearance = config.appearance
	local rendering = config.rendering or {}

	local curve_config = rendering.curve or {}
	local bars_config = rendering.bars or {}

	local function get_point(index, width, height)
		local count = #history

		local x

		if count <= 1 then
			x = width
		else
			x = ((index - 1) / (count - 1)) * width
		end

		local y = height - (history[index] / 100) * height

		return x, y
	end

	-- Catmull-Rom interpolation converted to cubic Bezier.
	local function get_curve_controls(index, width, height)
		local count = #history

		local _, p0y = get_point(math.max(1, index - 1), width, height)

		local p1x, p1y = get_point(index, width, height)
		local p2x, p2y = get_point(index + 1, width, height)

		local _, p3y = get_point(math.min(count, index + 2), width, height)

		local tension = curve_config.tension or 1.0
		local factor = tension / 6

		local cp1x = p1x + (p2x - (index > 1 and get_point(index - 1, width, height) or p1x)) * factor
		local cp1y = p1y + (p2y - p0y) * factor

		local cp2x = p2x
			- ((index + 2 <= count and select(1, get_point(index + 2, width, height)) or p2x) - p1x) * factor
		local cp2y = p2y - (p3y - p1y) * factor

		cp1y = clamp(cp1y, 0, height)
		cp2y = clamp(cp2y, 0, height)

		return cp1x, cp1y, cp2x, cp2y, p2x, p2y
	end

	-- Append curve segments to the current Cairo path.
	local function append_curve_path(cr, width, height)
		for i = 1, #history - 1 do
			local cp1x, cp1y, cp2x, cp2y, x2, y2 = get_curve_controls(i, width, height)

			cr:curve_to(cp1x, cp1y, cp2x, cp2y, x2, y2)
		end
	end

	-- Style A: Smooth line + filled area.
	local function draw_area(cr, width, height)
		local count = #history

		if count == 0 then
			return
		end

		local first_x, first_y = get_point(1, width, height)
		local last_x = get_point(count, width, height)

		-- Filled area.
		cr:move_to(first_x, height)
		cr:line_to(first_x, first_y)

		if count > 1 and curve_config.enabled then
			append_curve_path(cr, width, height)
		else
			for i = 2, count do
				local x, y = get_point(i, width, height)
				cr:line_to(x, y)
			end
		end

		cr:line_to(last_x, height)
		cr:close_path()

		set_color(cr, get_color(history[count]), appearance.area_opacity or 0.16)

		cr:fill()

		-- Draw the colored line.
		if count == 1 then
			local x, y = get_point(1, width, height)

			set_color(cr, get_color(history[1]))
			cr:arc(x, y, 2, 0, math.pi * 2)
			cr:fill()

			return
		end

		cr:set_line_width(appearance.line_width or 2)
		cr:set_line_cap(1)
		cr:set_line_join(1)

		for i = 1, count - 1 do
			local x1, y1 = get_point(i, width, height)
			local x2, y2 = get_point(i + 1, width, height)

			local average = (history[i] + history[i + 1]) / 2

			set_color(cr, get_color(average))

			cr:move_to(x1, y1)

			if curve_config.enabled then
				local cp1x, cp1y, cp2x, cp2y = get_curve_controls(i, width, height)

				cr:curve_to(cp1x, cp1y, cp2x, cp2y, x2, y2)
			else
				cr:line_to(x2, y2)
			end

			cr:stroke()
		end
	end

	-- Style B: Individual colored bars.
	local function draw_bars(cr, width, height)
		local count = #history

		if count == 0 then
			return
		end

		local requested_gap = appearance.bar_gap or 2
		local requested_width = appearance.bar_width or 5

		local bar_gap = math.min(requested_gap, (width / count) * 0.2)

		local available_width = width - math.max(0, count - 1) * bar_gap

		local bar_width = math.min(requested_width, available_width / count)

		local total_width = count * bar_width + math.max(0, count - 1) * bar_gap

		local offset = math.max(0, width - total_width)

		local rounded = bars_config.rounded ~= false
		local radius = bars_config.radius or 1

		for i, usage in ipairs(history) do
			local x = offset + (i - 1) * (bar_width + bar_gap)

			local bar_height = math.max(1, height * usage / 100)
			local y = height - bar_height

			set_color(cr, get_color(usage))

			if rounded then
				drawing.rounded_rectangle(cr, x, y, bar_width, bar_height, radius)
			else
				cr:rectangle(x, y, bar_width, bar_height)
			end

			cr:fill()
		end
	end

	graph.draw = function(_, _, cr, width, height)
		cr:save()
		cr:translate(1, 1)

		width = math.max(1, width - 2)
		height = math.max(1, height - 2)

		if config.style == "B" then
			draw_bars(cr, width, height)
		else
			draw_area(cr, width, height)
		end

		cr:restore()
	end

	graph.fit = function()
		return config.width or 110, config.height or 28
	end

	return graph
end

local function create()
	local history = {}

	local state = cpu.get_state()

	local current_usage = state.usage or 0
	local processes = state.processes or {}

	local graph = create_graph(history)
	local percentage = wibox.widget.textbox()
	percentage.font = (beautiful.widget_fonts.cpu_text or beautiful.widget_fonts.cpu).string

	local layout = wibox.layout.fixed.horizontal()
	layout.spacing = 6

	layout:add(graph)

	if config.show_percentage then
		layout:add(percentage)
	end

	local widget = wibox.container.background(layout)

	-- Optional display-only EMA smoothing.
	local smoothing_config = (config.rendering or {}).smoothing or {}

	local smoothed_usage

	local last_markup

	local function update_percentage(usage)
		local color = get_color(usage)

		local markup = string.format('<span foreground="%s">%d%%</span>', color, math.floor(usage + 0.5))

		-- set_markup always invalidates layout, so skip unchanged text.
		if markup ~= last_markup then
			last_markup = markup
			percentage:set_markup(markup)
		end
	end

	local function update_graph(usage)
		current_usage = usage

		local display_usage = usage

		if smoothing_config.enabled then
			local alpha = clamp(smoothing_config.alpha or 0.35, 0, 1)

			if smoothed_usage == nil then
				smoothed_usage = usage
			else
				smoothed_usage = alpha * usage + (1 - alpha) * smoothed_usage
			end

			display_usage = smoothed_usage
		else
			smoothed_usage = nil
		end

		history[#history + 1] = display_usage

		local max_history = config.history or 30

		if #history > max_history then
			table.remove(history, 1)
		end

		update_percentage(usage)

		graph:emit_signal("widget::redraw_needed")
	end

	local function update_tooltip()
		local lines = {
			"CPU",
			"",
			"Model: " .. state.model,
			string.format("Usage: %.1f%%", current_usage),
		}

		if (config.processes or {}).enabled then
			lines[#lines + 1] = ""
			lines[#lines + 1] = "Top processes:"

			if #processes == 0 then
				lines[#lines + 1] = "  No process data"
			end

			for i, process in ipairs(processes) do
				lines[#lines + 1] = string.format("  %d. %s  %.1f%%", i, process.name, process.usage)
			end

			lines[#lines + 1] = ""
			lines[#lines + 1] = "Process CPU: lifetime average"
		end

		lines[#lines + 1] = ""
		lines[#lines + 1] = "Click to open Task Manager"

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

		widget:connect_signal("mouse::enter", function()
			cpu.refresh_processes(config)
		end)
	end

	widget:buttons(gears.table.join(awful.button({}, 1, function()
		awful.spawn(config.task_manager)
	end)))

	awesome.connect_signal("cpu::update", update_graph)

	awesome.connect_signal("cpu::processes", function(data)
		processes = data
	end)

	update_percentage(current_usage)

	if current_usage > 0 then
		history[#history + 1] = current_usage
	end

	cpu.start(config)

	return widget
end

M.new = create

return M
