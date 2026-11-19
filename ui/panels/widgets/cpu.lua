local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local config = require("config.cpu")
local cpu = require("core.cpu")

local M = {}

-- Convert #RRGGBB to normalized RGB.
local function parse_color(color)
	color = color:gsub("#", "")

	return tonumber(color:sub(1, 2), 16) / 255, tonumber(color:sub(3, 4), 16) / 255, tonumber(color:sub(5, 6), 16) / 255
end

local function get_color(usage)
	local colors = config.colors

	local first = colors[1]
	local last = colors[#colors]

	if usage <= first.threshold then
		return first.color
	end

	if usage >= last.threshold then
		return last.color
	end

	for i = 1, #colors - 1 do
		local a = colors[i]
		local b = colors[i + 1]

		if usage >= a.threshold and usage <= b.threshold then
			local t = (usage - a.threshold) / (b.threshold - a.threshold)

			local ar, ag, ab = parse_color(a.color)
			local br, bg, bb = parse_color(b.color)

			local r = ar + (br - ar) * t
			local g = ag + (bg - ag) * t
			local blue = ab + (bb - ab) * t

			return string.format(
				"#%02x%02x%02x",
				math.floor(r * 255 + 0.5),
				math.floor(g * 255 + 0.5),
				math.floor(blue * 255 + 0.5)
			)
		end
	end

	return last.color
end

local function set_color(cr, color, alpha)
	local r, g, b = parse_color(color)

	cr:set_source_rgba(r, g, b, alpha or 1)
end

local function clamp(value, minimum, maximum)
	return math.max(minimum, math.min(maximum, value))
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

	-- Calculate Catmull-Rom control points for one segment.
	local function get_curve_controls(index, width, height)
		local count = #history

		local p0x, p0y = get_point(math.max(1, index - 1), width, height)

		local p1x, p1y = get_point(index, width, height)
		local p2x, p2y = get_point(index + 1, width, height)

		local p3x, p3y = get_point(math.min(count, index + 2), width, height)

		local tension = curve_config.tension or 1.0
		local factor = tension / 6

		local cp1x = p1x + (p2x - p0x) * factor
		local cp1y = p1y + (p2y - p0y) * factor

		local cp2x = p2x - (p3x - p1x) * factor
		local cp2y = p2y - (p3y - p1y) * factor

		-- Prevent vertical overshooting.
		cp1y = clamp(cp1y, 0, height)
		cp2y = clamp(cp2y, 0, height)

		return cp1x, cp1y, cp2x, cp2y, p2x, p2y
	end

	-- Draw a complete smooth curve path.
	local function draw_curve_path(cr, width, height)
		local count = #history

		local first_x, first_y = get_point(1, width, height)

		cr:move_to(first_x, first_y)

		for i = 1, count - 1 do
			local cp1x, cp1y, cp2x, cp2y, x2, y2 = get_curve_controls(i, width, height)

			cr:curve_to(cp1x, cp1y, cp2x, cp2y, x2, y2)
		end
	end

	-- Style A: Smooth gradient line + filled area.
	local function draw_area(cr, width, height)
		local count = #history

		if count == 0 then
			return
		end

		local first_x, first_y = get_point(1, width, height)

		-- Filled area.
		cr:move_to(first_x, height)
		cr:line_to(first_x, first_y)

		if count > 1 and curve_config.enabled then
			draw_curve_path(cr, width, height)
		else
			for i = 2, count do
				local x, y = get_point(i, width, height)
				cr:line_to(x, y)
			end
		end

		local last_x = get_point(count, width, height)

		cr:line_to(last_x, height)
		cr:close_path()

		set_color(cr, get_color(history[count]), appearance.area_opacity or 0.16)

		cr:fill()

		-- Draw individually colored line segments.
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

	-- Draw a rounded rectangle for Style B.
	local function rounded_rectangle(cr, x, y, width, height, radius)
		radius = math.min(radius, width / 2, height / 2)

		if radius <= 0 then
			cr:rectangle(x, y, width, height)
			return
		end

		cr:new_sub_path()

		cr:arc(x + width - radius, y + radius, radius, -math.pi / 2, 0)

		cr:arc(x + width - radius, y + height - radius, radius, 0, math.pi / 2)

		cr:arc(x + radius, y + height - radius, radius, math.pi / 2, math.pi)

		cr:arc(x + radius, y + radius, radius, math.pi, math.pi * 1.5)

		cr:close_path()
	end

	-- Style B: Individual colored bars.
	local function draw_bars(cr, width, height)
		local count = #history

		if count == 0 then
			return
		end

		local requested_gap = appearance.bar_gap or 2
		local requested_width = appearance.bar_width or 5

		-- Adapt bar dimensions to available graph width.
		local bar_gap = math.min(requested_gap, (width / count) * 0.2)

		local available_width = width - math.max(0, count - 1) * bar_gap

		local bar_width = math.min(requested_width, available_width / count)

		-- Keep shorter histories right-aligned.
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
				rounded_rectangle(cr, x, y, bar_width, bar_height, radius)
			else
				cr:rectangle(x, y, bar_width, bar_height)
			end

			cr:fill()
		end
	end

	graph.draw = function(_, _, cr, width, height)
		cr:save()

		-- Leave a little room around the graph edges.
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

	local layout = wibox.layout.fixed.horizontal()
	layout.spacing = 6

	layout:add(graph)

	if config.show_percentage then
		layout:add(percentage)
	end

	local widget = wibox.container.background(layout)

	-- EMA state is used only for graph display.
	local smoothing_config = (config.rendering or {}).smoothing or {}

	local smoothed_usage

	local function update_percentage(usage)
		local color = get_color(usage)

		percentage:set_markup(string.format('<span foreground="%s">%d%%</span>', color, math.floor(usage + 0.5)))
	end

	local function update_graph(usage)
		-- Preserve actual CPU usage for the tooltip and percentage.
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

		if config.processes.enabled then
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

	if config.tooltip.enabled then
		awful.tooltip({
			objects = { widget },
			timer_function = update_tooltip,
			preferred_positions = { "top", "bottom" },
			margin_leftright = 8,
			margin_topbottom = 6,
		})
	end

	widget:buttons(gears.table.join(awful.button({}, 1, function()
		awful.spawn(config.task_manager)
	end)))

	awesome.connect_signal("cpu::update", update_graph)

	awesome.connect_signal("cpu::processes", function(data)
		processes = data
	end)

	-- Initial state.
	update_percentage(current_usage)

	if current_usage > 0 then
		history[#history + 1] = current_usage
	end

	cpu.start(config)

	return widget
end

M.new = create

return M
