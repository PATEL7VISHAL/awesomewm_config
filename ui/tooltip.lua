local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")

local windows = require("config.windows")

local M = {}

local escape = gears.string.xml_escape

M.escape = escape

local pi = math.pi

-- Side of the screen the panel sits on; tooltips open away from it.
local panel_position = "bottom"

function M.set_panel_position(position)
	panel_position = position
end

-- Rounded body with a triangular tail pointing at the widget.
-- `at_bottom` puts the tail on the bottom edge (tooltip above the widget).
local function bubble(cr, width, height, radius, tail, tail_x, at_bottom)
	local half_base = tail * 1.2
	local top = at_bottom and 0 or tail
	local bottom = at_bottom and height - tail or height

	tail_x = math.max(radius + half_base, math.min(width - radius - half_base, tail_x or width / 2))

	cr:new_sub_path()
	cr:arc(radius, top + radius, radius, pi, 1.5 * pi)

	if not at_bottom then
		cr:line_to(tail_x - half_base, top)
		cr:line_to(tail_x, 0)
		cr:line_to(tail_x + half_base, top)
	end

	cr:arc(width - radius, top + radius, radius, -0.5 * pi, 0)
	cr:arc(width - radius, bottom - radius, radius, 0, 0.5 * pi)

	if at_bottom then
		cr:line_to(tail_x + half_base, bottom)
		cr:line_to(tail_x, height)
		cr:line_to(tail_x - half_base, bottom)
	end

	cr:arc(radius, bottom - radius, radius, 0.5 * pi, pi)
	cr:close_path()
end

-- Shared tooltip constructor so every widget gets the same geometry and theme.
-- The tooltip opens centered on the widget, away from the panel, with a tail
-- aimed at the widget even when the box is pushed back inside the screen.
function M.new(args)
	args = gears.table.crush({
		mode = "outside",
		preferred_positions = { panel_position == "top" and "bottom" or "top" },
		preferred_alignments = { "middle" },
		margin_leftright = windows.tooltip_margin_leftright,
		margin_topbottom = windows.tooltip_margin_topbottom,
	}, args or {})

	local tail = windows.tooltip_tail_size
	local radius = windows.popup_corner_radius
	local at_bottom = args.preferred_positions[1] ~= "bottom"
	local tail_x

	args.shape = function(cr, width, height)
		bubble(cr, width, height, radius, tail, tail_x, at_bottom)
	end

	local tip = awful.tooltip(args)

	-- Reserve room for the tail on the side that faces the widget.
	if at_bottom then
		tip.marginbox:set_bottom(windows.tooltip_margin_topbottom + tail)
	else
		tip.marginbox:set_top(windows.tooltip_margin_topbottom + tail)
	end

	tip:connect_signal("property::visible", function()
		if not tip._private.visible then
			return
		end

		-- Widget geometry is relative to the wibox it lives in; resolve it to
		-- screen coordinates so placement also works on secondary screens.
		local geometry = tip._private.widget_geometry
		local source = mouse.current_wibox
		local wb = tip:get_wibox()

		tail_x = nil

		if geometry and source then
			local origin = source:geometry()
			local center = origin.x + geometry.x + geometry.width / 2
			local box = wb:geometry()
			local gap = windows.tooltip_gap

			wb.x = math.floor(center - box.width / 2)

			if at_bottom then
				wb.y = origin.y + geometry.y - box.height - gap
			else
				wb.y = origin.y + geometry.y + geometry.height + gap
			end

			awful.placement.no_offscreen(wb, { honor_workarea = true })

			tail_x = center - wb.x
		end

		tip.backgroundbox:emit_signal("widget::redraw_needed")
	end)

	return tip
end

-- Build Pango markup from a title and rows. Every value is escaped, because
-- awful.tooltip renders timer_function output as markup (process names may
-- contain "<" or "&").
--
-- Row forms: "text", { "Label", "value" }, { section = "Heading" }, "" (gap).
function M.format(title, rows, footer)
	local accent = beautiful.tooltip_accent or beautiful.fg_normal
	local muted = beautiful.tooltip_muted or beautiful.fg_minimize or beautiful.fg_normal

	local lines = {}

	if title then
		lines[#lines + 1] = string.format('<span foreground="%s" weight="bold">%s</span>', accent, escape(title))
	end

	for _, row in ipairs(rows or {}) do
		if type(row) == "string" then
			lines[#lines + 1] = escape(row)
		elseif row.section then
			lines[#lines + 1] = string.format(
				'<span foreground="%s" size="small" weight="bold">%s</span>',
				muted,
				escape(row.section:upper())
			)
		else
			lines[#lines + 1] =
				string.format('<span foreground="%s">%s</span>  %s', muted, escape(row[1]), escape(row[2]))
		end
	end

	if footer then
		lines[#lines + 1] = string.format('<span foreground="%s" size="small">%s</span>', muted, escape(footer))
	end

	return table.concat(lines, "\n")
end

return M
