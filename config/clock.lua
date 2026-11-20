local dpi = require("beautiful.xresources").apply_dpi
local beautiful = require("beautiful")

local indicator = beautiful.panel_indicator or {}
local panel_bg = beautiful.panel_bg or beautiful.bg_normal or "#20242c"
local panel_fg = beautiful.panel_fg or beautiful.fg_normal or "#e6e8eb"
local accent = beautiful.panel_accent or indicator.selected or "#3985ed"

return {
	format = "%a %b %e  •  %I:%M:%S %p",

	calendar = {
		width = dpi(276),
		padding = dpi(14),

		cell_width = dpi(32),
		cell_height = dpi(32),
		weekday_height = dpi(24),

		spacing = dpi(4),
		section_spacing = dpi(10),

		background = panel_bg,
		foreground = panel_fg,
		muted = indicator.empty or "#858d99",
		border = beautiful.panel_border or "#ffffff20",
		separator = beautiful.panel_separator or "#ffffff18",

		header_foreground = panel_fg,
		navigation_foreground = accent,
		navigation_hover = "#ffffff12",

		today_background = accent,
		today_foreground = panel_bg,

		sunday_foreground = indicator.urgent or "#e88b8b",

		radius = dpi(12),
		cell_radius = dpi(7),
		navigation_radius = dpi(6),

		offset = dpi(8),
	},
}
