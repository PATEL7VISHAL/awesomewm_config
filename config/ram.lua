local beautiful = require("beautiful")

return {
	enabled = true,

	-- Memory polling interval in seconds.
	interval = 3,

	-- Minimum interval between tooltip-triggered process samples.
	process_interval = 5,

	-- Number of RAM-heavy processes in tooltip.
	process_limit = 5,

	appearance = {
		-- nil = use available panel height.
		size = nil,

		thickness = 4,

		-- Center percentage.
		font_family = beautiful.widget_fonts.ram.family or "Ubuntu Mono",
		font_size = beautiful.widget_fonts.ram.size or 11,
		font_weight = beautiful.widget_fonts.ram.weight or "bold",

		-- Pure white.
		progress_color = "#ffffff",
		text_color = "#ffffff",

		-- Translucent white track.
		track_color = "#ffffff",
		track_opacity = 0.18,
	},

	tooltip = {
		enabled = true,
	},
}
