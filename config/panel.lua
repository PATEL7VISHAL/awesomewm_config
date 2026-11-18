local dpi = require("beautiful.xresources").apply_dpi

return {
	style = "bottom",
	presets = {
		bottom = {
			position = "bottom",
			height = dpi(32),
			margin = dpi(4),
			spacing = dpi(4),
			workspace_style = "indicator", -- indicator or pill
			clock_format = "%a %b %e  %H:%M:%S",
		},
		top = {
			position = "top",
			height = dpi(34),
			margin = dpi(4),
			spacing = dpi(4),
			workspace_style = "pill",
			clock_format = "%a %b %e  %H:%M",
		},
	},
}
