local dpi = require("beautiful.xresources").apply_dpi

---@type NotificationSettings
return {
	-- naughty position: top_right, top_middle, bottom_right, ...
	position = "top_right",

	width = dpi(360),
	icon_size = dpi(40),
	padding = dpi(12),
	spacing = dpi(8),

	-- Urgency stripe on the left edge.
	accent_width = dpi(4),

	-- Seconds; 0 keeps the notification until it is dismissed.
	timeouts = {
		low = 3,
		normal = 6,
		critical = 0,
	},
}
