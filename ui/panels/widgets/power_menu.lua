local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local config = require("config.power_menu")
local icons = require("theme.icons")

local M = {}

local dpi = beautiful.xresources.apply_dpi

local function rounded(radius)
	return function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, radius)
	end
end

local function make_action_row(action, popup)
	local icon = wibox.widget({
		image = gears.color.recolor_image(icons[action.icon], action.color),
		resize = true,
		forced_width = config.popup.icon_size,
		forced_height = config.popup.icon_size,
		widget = wibox.widget.imagebox,
	})

	local icon_tile = wibox.widget({
		{
			icon,
			halign = "center",
			valign = "center",
			widget = wibox.container.place,
		},
		forced_width = config.popup.icon_tile_size,
		forced_height = config.popup.icon_tile_size,
		bg = action.color .. "20",
		shape = rounded(dpi(10)),
		widget = wibox.container.background,
	})

	local label = wibox.widget({
		text = action.label,
		font = beautiful.font or "sans 11",
		align = "left",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	local row_content = wibox.widget({
		{
			icon_tile,
			{
				label,
				left = dpi(12),
				widget = wibox.container.margin,
			},
			spacing = dpi(2),
			layout = wibox.layout.fixed.horizontal,
		},
		left = dpi(10),
		right = dpi(10),
		widget = wibox.container.margin,
	})

	local row = wibox.widget({
		row_content,
		forced_width = config.popup.width - config.popup.padding * 2 - config.popup.border_width * 2,
		forced_height = config.popup.row_height,
		bg = config.popup.row_background,
		fg = config.popup.foreground,
		shape = rounded(config.popup.row_radius),
		widget = wibox.container.background,
	})

	row:connect_signal("mouse::enter", function()
		row.bg = config.popup.row_hover
	end)

	row:connect_signal("mouse::leave", function()
		row.bg = config.popup.row_background
	end)

	row:buttons(gears.table.join(awful.button({}, 1, function()
		popup.close()

		if action.id == "logout" then
			awesome.quit()
		elseif action.command then
			awful.spawn.with_shell(action.command)
		end
	end)))

	return row
end

local function make_popup(s)
	local popup

	local rows = wibox.layout.fixed.vertical()
	rows.spacing = config.popup.row_spacing

	for _, action in ipairs(config.actions) do
		rows:add(make_action_row(action, {
			close = function()
				popup.visible = false
			end,
		}))
	end

	local card_content = wibox.widget({
		rows,
		margins = config.popup.padding,
		widget = wibox.container.margin,
	})

	local card = wibox.widget({
		card_content,
		bg = config.popup.background,
		fg = config.popup.foreground,
		border_width = config.popup.border_width,
		border_color = config.popup.border,
		shape = rounded(config.popup.radius),
		widget = wibox.container.background,
	})

	popup = awful.popup({
		screen = s,
		visible = false,
		ontop = true,
		type = "utility",
		width = config.popup.width,
		height = config.popup.padding * 2
			+ config.popup.border_width * 2
			+ (#config.actions * config.popup.row_height)
			+ ((#config.actions - 1) * config.popup.row_spacing),

		bg = config.popup.background,
		border_width = 0,

		offset = {
			y = config.popup.offset,
		},

		widget = card,
	})

	return popup
end

local function place_popup(popup, screen, panel_position)
	local anchor = mouse.current_widget_geometry
	if not anchor then
		return false
	end

	local screen_geometry = screen.geometry
	local panel_geometry = screen.panel and screen.panel:geometry()
	local x = anchor.x + anchor.width - popup.width
	local y

	if panel_position == "top" then
		y = (panel_geometry and panel_geometry.y + panel_geometry.height or anchor.y + anchor.height)
			+ config.popup.offset
	else
		y = (panel_geometry and panel_geometry.y or anchor.y) - popup.height - config.popup.offset
	end

	x = math.max(screen_geometry.x, math.min(x, screen_geometry.x + screen_geometry.width - popup.width))
	y = math.max(screen_geometry.y, math.min(y, screen_geometry.y + screen_geometry.height - popup.height))

	popup:geometry({
		x = x,
		y = y,
		width = popup.width,
		height = popup.height,
	})

	return true
end

local function make_button(popup, screen, panel_position)
	local icon = wibox.widget({
		image = gears.color.recolor_image(icons.power, beautiful.panel_fg or beautiful.fg_normal),
		resize = true,
		forced_width = config.button.icon_size,
		forced_height = config.button.icon_size,
		widget = wibox.widget.imagebox,
	})

	local button = wibox.widget({
		{
			icon,
			halign = "center",
			valign = "center",
			widget = wibox.container.place,
		},
		forced_width = config.button.size,
		forced_height = config.button.size,
		bg = config.button.background,
		shape = rounded(dpi(9)),
		widget = wibox.container.background,
	})

	button:connect_signal("mouse::enter", function()
		button.bg = config.button.hover_background
	end)

	button:connect_signal("mouse::leave", function()
		button.bg = config.button.background
	end)

	button:buttons(gears.table.join(awful.button({}, 1, function()
		if popup.visible then
			popup.visible = false
			button.bg = config.button.background
		else
			if place_popup(popup, screen, panel_position) then
				popup.visible = true
				button.bg = config.button.hover_background
			end
		end
	end)))

	return button
end

function M.new(s, opts)
	if not config.enabled then
		return nil
	end

	local popup = make_popup(s)
	local button = make_button(popup, s, opts and opts.position)

	local keygrabber = awful.keygrabber({
		keypressed_callback = function(_, _, key)
			if key == "Escape" then
				popup.visible = false
				button.bg = config.button.background
				return false
			end
		end,
	})

	popup:connect_signal("property::visible", function(_, visible)
		if visible then
			button.bg = config.button.hover_background
			keygrabber:start()
		else
			button.bg = config.button.background
			keygrabber:stop()
		end
	end)

	return button
end

return M
