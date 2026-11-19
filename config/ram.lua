return {
	enabled = true,

	-- Memory polling interval in seconds.
	interval = 3,

	-- Process collection interval in seconds.
	process_interval = 5,

	-- Number of RAM-heavy processes in tooltip.
	process_limit = 5,

	appearance = {
		-- nil = use available panel height.
		size = nil,

		thickness = 4,

		-- Center percentage.
		font_family = "Ubuntu Mono",
		font_size = 11,
		font_weight = "bold",

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
