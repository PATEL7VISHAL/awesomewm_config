local dpi = require("beautiful.xresources").apply_dpi
local beautiful = require("beautiful")

return {
	enabled = true,

	button = {
		size = dpi(34),
		icon_size = dpi(22),
		background = beautiful.exit_theme.button_background or beautiful.panel_bg,
		hover_background = "#ffffff12",
	},

	popup = {
		width = dpi(238),
		padding = dpi(8),
		row_height = dpi(42),
		row_spacing = dpi(4),

		background = beautiful.exit_theme.background or beautiful.panel_bg or beautiful.bg_normal,
		foreground = beautiful.exit_theme.foreground or beautiful.panel_fg or beautiful.fg_normal,
		border = beautiful.exit_theme.button_border or beautiful.panel_border,
		border_width = dpi(1),
		radius = dpi(14),

		row_background = beautiful.exit_theme.button_background or beautiful.panel_bg,
		row_hover = beautiful.exit_theme.button_hover_background or beautiful.panel_border,
		row_radius = dpi(10),

		icon_size = dpi(20),
		icon_tile_size = dpi(34),

		offset = dpi(8),
	},

	actions = {
		{
			id = "shutdown",
			label = "Shutdown",
			icon = "power",
			command = "systemctl poweroff",
			color = beautiful.exit_theme.actions.poweroff or "#ff6b6b",
		},
		{
			id = "restart",
			label = "Restart",
			icon = "restart",
			command = "systemctl reboot",
			color = beautiful.exit_theme.actions.reboot or "#f3a712",
		},
		{
			id = "logout",
			label = "Logout",
			icon = "logout",
			color = beautiful.exit_theme.actions.logout or "#4ecdc4",
		},
		{
			id = "sleep",
			label = "Sleep",
			icon = "sleep",
			command = "systemctl suspend",
			color = beautiful.exit_theme.actions.suspend or "#1dd1a1",
		},
	},
}
