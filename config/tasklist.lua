local dpi = require("beautiful.xresources").apply_dpi
local beautiful = require("beautiful")

return {
	item_size = dpi(30),
	icon_size = dpi(28),
	icon_padding = dpi(2),

	dot_size = dpi(7),

	colors = {
		focused = beautiful.panel_indicator.selected or "#A9B4AA",
		urgent = beautiful.panel_indicator.urgent or "#F36B78",
	},

	spacing = dpi(5),
}
