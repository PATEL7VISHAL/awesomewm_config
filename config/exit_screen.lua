local dpi = require("beautiful.xresources").apply_dpi

return {
	enabled = true,

	-- Button appearance
	button_size = dpi(120),
	icon_padding = dpi(26),
	icon_size = dpi(68),

	button_spacing = dpi(56),
	label_spacing = dpi(14),

	label_font = nil, -- Falls back to beautiful.font
	label_size = dpi(13),

	-- Commands
	commands = {
		poweroff = "poweroff",
		reboot = "reboot",
		suspend = "systemctl suspend",
	},

	-- Keyboard shortcuts
	shortcuts = {
		poweroff = "p",
		reboot = "r",
		suspend = "s",
		logout = "e",
		lock = "l",
		cancel = "Escape",
	},
}
