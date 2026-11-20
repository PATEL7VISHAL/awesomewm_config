local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local config = require("config.clock")
local dpi = beautiful.xresources.apply_dpi

local c = config.calendar
local M = {}

local function make_text(text, color, font)
	return wibox.widget({
		markup = string.format('<span foreground="%s">%s</span>', color or c.foreground, text),
		align = "center",
		valign = "center",
		font = font or beautiful.font,
		widget = wibox.widget.textbox,
	})
end

local function make_cell(text, background, foreground, width, height)
	local label = make_text(text, foreground)

	label.forced_width = width
	label.forced_height = height

	return wibox.container.background(label, background, gears.shape.rounded_rect, c.cell_radius)
end

local function make_navigation_button(symbol, callback)
	local label = make_text(symbol, c.navigation_foreground)

	label.forced_width = dpi(28)
	label.forced_height = dpi(26)

	local button = wibox.container.background(label, nil, gears.shape.rounded_rect, c.navigation_radius)

	button:connect_signal("mouse::enter", function()
		button.bg = c.navigation_hover
	end)

	button:connect_signal("mouse::leave", function()
		button.bg = nil
	end)

	button:buttons(gears.table.join(awful.button({}, 1, callback)))

	return button
end

local function normalize_month(year, month)
	local timestamp = os.time({
		year = year,
		month = month,
		day = 1,
	})

	local normalized = os.date("*t", timestamp)

	return normalized.year, normalized.month
end

local function days_in_month(year, month)
	return tonumber(os.date(
		"%d",
		os.time({
			year = year,
			month = month + 1,
			day = 0,
		})
	))
end

local function month_title(year, month)
	return os.date(
		"%B %Y",
		os.time({
			year = year,
			month = month,
			day = 1,
		})
	)
end

local function build_calendar(year, month, previous, next_month)
	local today = os.date("*t")

	local is_current_month = today.year == year and today.month == month

	local first_day = os.time({
		year = year,
		month = month,
		day = 1,
	})

	-- Monday-first: Monday = 1, Sunday = 7.
	local weekday_offset = (tonumber(os.date("%w", first_day)) + 6) % 7

	local total_days = days_in_month(year, month)
	local row_count = math.ceil((weekday_offset + total_days) / 7)

	local content = wibox.layout.fixed.vertical()
	content.spacing = c.spacing

	-- Header
	local header = wibox.layout.align.horizontal()

	header:set_left(make_navigation_button("‹", previous))

	header:set_middle(make_text(month_title(year, month), c.header_foreground, beautiful.font))

	header:set_right(make_navigation_button("›", next_month))

	header.forced_height = dpi(30)

	content:add(header)

	-- Separator
	content:add(wibox.widget({
		forced_height = dpi(1),
		color = c.separator,
		widget = wibox.widget.separator,
	}))

	-- Weekday labels
	local weekdays = {
		"Mon",
		"Tue",
		"Wed",
		"Thu",
		"Fri",
		"Sat",
		"Sun",
	}

	local weekday_row = wibox.layout.fixed.horizontal()
	weekday_row.spacing = c.spacing

	for index, name in ipairs(weekdays) do
		local color = index == 7 and c.sunday_foreground or c.muted

		local cell = make_text(name, color)
		cell.forced_width = c.cell_width
		cell.forced_height = c.weekday_height

		weekday_row:add(cell)
	end

	content:add(weekday_row)

	-- Date grid
	for row = 1, row_count do
		local week = wibox.layout.fixed.horizontal()
		week.spacing = c.spacing

		for column = 1, 7 do
			local cell_index = (row - 1) * 7 + column
			local date_number = cell_index - weekday_offset

			if date_number >= 1 and date_number <= total_days then
				local is_today = is_current_month and date_number == today.day

				local is_sunday = column == 7

				local background = is_today and c.today_background or nil

				local foreground = is_today and c.today_foreground
					or (is_sunday and c.sunday_foreground or c.foreground)

				week:add(make_cell(tostring(date_number), background, foreground, c.cell_width, c.cell_height))
			else
				week:add(make_cell("", nil, c.foreground, c.cell_width, c.cell_height))
			end
		end

		content:add(week)
	end

	return content
end

local function place_popup(popup, screen, panel_position)
	local anchor = mouse.current_widget_geometry

	if not anchor then
		return
	end

	local screen_geometry = screen.geometry
	local panel_geometry = screen.panel and screen.panel:geometry()
	local panel_x = panel_geometry and panel_geometry.x or screen_geometry.x
	local panel_y = panel_geometry and panel_geometry.y or anchor.y
	local panel_width = panel_geometry and panel_geometry.width or screen_geometry.width
	local panel_height = panel_geometry and panel_geometry.height or anchor.height
	local x = anchor.x + anchor.width / 2 - popup.width / 2
	local y

	if panel_position == "top" then
		y = panel_y + panel_height + c.offset
	else
		y = panel_y - popup.height - c.offset
	end

	x = math.max(screen_geometry.x, math.min(x, screen_geometry.x + screen_geometry.width - popup.width))
	x = math.max(panel_x, math.min(x, panel_x + panel_width - popup.width))
	y = math.max(screen_geometry.y, math.min(y, screen_geometry.y + screen_geometry.height - popup.height))

	popup:geometry({
		x = x,
		y = y,
		width = popup.width,
		height = popup.height,
	})
end

local function new(screen, format, opts)
	local clock = wibox.widget.textclock(format or config.format)

	local now = os.date("*t")
	local displayed_year = now.year
	local displayed_month = now.month

	local popup = awful.popup({
		screen = screen or awful.screen.focused(),
		ontop = true,
		visible = false,

		border_width = dpi(1),
		border_color = c.border,
		bg = c.background,
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, c.radius)
		end,

		maximum_width = c.width,
		width = c.width,
		offset = { y = c.offset },

		widget = {
			{
				id = "calendar_content",
				widget = wibox.container.place,
			},
			margins = c.padding,
			widget = wibox.container.margin,
		},
	})

	local function refresh_calendar()
		local content = build_calendar(displayed_year, displayed_month, function()
			displayed_year, displayed_month = normalize_month(displayed_year, displayed_month - 1)

			refresh_calendar()
		end, function()
			displayed_year, displayed_month = normalize_month(displayed_year, displayed_month + 1)

			refresh_calendar()
		end)

		popup.widget:get_children_by_id("calendar_content")[1].widget = content
	end

	local function change_month(amount)
		displayed_year, displayed_month = normalize_month(displayed_year, displayed_month + amount)

		refresh_calendar()
	end

	local function reset_calendar()
		local current = os.date("*t")

		displayed_year = current.year
		displayed_month = current.month
	end

	local function show_popup()
		if popup.visible then
			return
		end

		reset_calendar()
		refresh_calendar()

		place_popup(popup, screen, opts and opts.position)
		popup.visible = true
	end

	local function hide_popup()
		popup.visible = false
	end

	local hide_timer
	local clock_hover = false
	local popup_hover = false

	local function schedule_hide()
		if hide_timer then
			hide_timer:stop()
		end

		hide_timer = gears.timer.start_new(0.2, function()
			hide_timer = nil

			if not clock_hover and not popup_hover then
				hide_popup()
			end

			return false
		end)
	end

	-- Show while the pointer is over the clock.
	clock:connect_signal("mouse::enter", function()
		clock_hover = true
		show_popup()
	end)

	clock:connect_signal("mouse::leave", function()
		clock_hover = false
		schedule_hide()
	end)
	popup:connect_signal("mouse::enter", function()
		popup_hover = true

		if hide_timer then
			hide_timer:stop()
			hide_timer = nil
		end
	end)
	popup:connect_signal("mouse::leave", function()
		popup_hover = false
		schedule_hide()
	end)

	-- Scroll up: previous month.
	-- Scroll down: next month.
	clock:buttons(gears.table.join(
		awful.button({}, 4, function()
			if popup.visible then
				change_month(-1)
			end
		end),

		awful.button({}, 5, function()
			if popup.visible then
				change_month(1)
			end
		end)
	))

	refresh_calendar()

	return clock
end

M.new = new

return M
