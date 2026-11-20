return {
	enabled = true,

	-- "A" = gradient area
	-- "B" = colored bars
	style = "A",

	interval = 1,
	history = 30,

	width = 110,
	height = 28,

	show_percentage = true,

	-- Green / White / Orange / Red
	colors = {
		{ threshold = 0, color = "#86e381" },
		{ threshold = 25, color = "#cdb6b4" },
		{ threshold = 55, color = "#faa377" },
		{ threshold = 80, color = "#f36b98" },
	},

	-- Graph appearance
	appearance = {
		line_width = 2,
		bar_width = 5,
		bar_gap = 2,
		area_opacity = 0.16,
	},

	-- Rendering improvements
	rendering = {
		curve = {
			enabled = true,
			tension = 1.0,
		},

		bars = {
			rounded = true,
			radius = 2,
		},

		-- Optional display-only smoothing.
		-- Does not change the actual CPU usage value.
		smoothing = {
			enabled = false,
			alpha = 0.35,
		},
	},

	processes = {
		enabled = true,
		-- Minimum interval between tooltip-triggered process samples.
		interval = 5,
		limit = 5,
	},

	task_manager = "xfce4-taskmanager",

	tooltip = {
		enabled = true,
	},
}
