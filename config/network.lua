local M = {}

M.enabled = true
M.interface = nil -- nil = automatically detect default route

-- Widest text used to reserve a fixed widget width (longer values are clipped).
M.max_text = "99.9 MB/s ↓"

M.sampling_interval = 1
M.interface_detection_interval = 5

-- Reference throughput for logarithmic meter scaling (bytes/second).
M.reference_speed = 10 * 1024 * 1024

M.appearance = {
	-- Bar dimensions.
	bar_width = 9,
	-- Adaptive height relative to the panel height.
	height_ratio = 0.62,
	min_height = 18,
	max_height = 38,

	radius = 3,

	-- Space between text and meters.
	spacing = 3,

	-- Number of visual levels.
	levels = 10,
}

M.colors = {
	download = "#e9c84b",
	upload = "#ed914b",
	track = "#ffffff18",
}

M.tooltip = {
	enabled = true,
}

return M
