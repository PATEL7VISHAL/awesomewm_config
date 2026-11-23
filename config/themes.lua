local dpi = require("beautiful.xresources").apply_dpi

local function font(family, size, weight)
	return {
		family = family,
		size = size,
		weight = weight or "normal",
		string = string.format("%s %s %d", family, weight or "normal", math.floor(dpi(size))),
	}
end

local common_fonts = {
	base = font("Ubuntu Sans", 11),
	clock = font("Ubuntu", 13, "bold"),
	calendar = font("Ubuntu", 13, "bold"),
	battery = font("Ubuntu Mono", 11, "bold"),
	network = font("Ubuntu", 11, "bold"),
	cpu = font("Ubuntu Mono", 11, "bold"),
	cpu_text = font("Ubuntu Mono", 11, "bold"),
	ram = font("Ubuntu Mono", 11, "bold"),
}

return {
	active = os.getenv("AWESOME_THEME") or "gruvbox",

	presets = {
		midnight = {
			panel = {
				bg = "#171A24",
				fg = "#DDE3F0",
				border = "#2A3040",
				accent = "#89B4FA",
				separator = "#3A4255",
				indicator = {
					selected = "#89B4FA",
					occupied = "#A6ADC8",
					empty = "#4C566A",
					urgent = "#F38BA8",
				},
			},
			widgets = {
				battery = {
					normal = "#A6E3A1",
					charging = "#74C7EC",
					warning = "#F9E2AF",
					critical = "#F38BA8",
					empty = "#717284",
					label = "#171A24",
				},
				cpu = {
					colors = {
						{ threshold = 0, color = "#A6E3A1" },
						{ threshold = 25, color = "#F9E2AF" },
						{ threshold = 55, color = "#FAB387" },
						{ threshold = 80, color = "#F38BA8" },
					},
				},
				ram = {
					progress = "#89B4FA",
					track = "#DDE3F0",
					text = "#DDE3F0",
					track_opacity = 0.18,
				},
			},
			exit = {
				background = "#171A24E6",
				foreground = "#DDE3F0",
				button_background = "#2A3040",
				button_hover_background = "#3A4255",
				button_border = "#4C566A",
				button_hover_border = "#89B4FA",
				actions = {
					poweroff = "#F38BA8",
					reboot = "#F9E2AF",
					suspend = "#74C7EC",
					logout = "#A6E3A1",
					lock = "#CBA6F7",
				},
			},
			fonts = common_fonts,
		},

		graphite = {
			panel = {
				bg = "#20252E",
				fg = "#E6EDF3",
				border = "#343C49",
				accent = "#7DD3FC",
				separator = "#465161",
				indicator = {
					selected = "#7DD3FC",
					occupied = "#A8B3C2",
					empty = "#596575",
					urgent = "#FF7B8A",
				},
			},
			widgets = {
				battery = {
					normal = "#B8E994",
					charging = "#7DD3FC",
					warning = "#F6D365",
					critical = "#FF7B8A",
					empty = "#687383",
					label = "#20252E",
				},
				cpu = {
					colors = {
						{ threshold = 0, color = "#B8E994" },
						{ threshold = 25, color = "#F6D365" },
						{ threshold = 55, color = "#F5A97F" },
						{ threshold = 80, color = "#FF7B8A" },
					},
				},
				ram = {
					progress = "#7DD3FC",
					track = "#E6EDF3",
					text = "#E6EDF3",
					track_opacity = 0.2,
				},
			},
			exit = {
				background = "#20252EE6",
				foreground = "#E6EDF3",
				button_background = "#343C49",
				button_hover_background = "#465161",
				button_border = "#596575",
				button_hover_border = "#7DD3FC",
				actions = {
					poweroff = "#FF7B8A",
					reboot = "#F6D365",
					suspend = "#7DD3FC",
					logout = "#B8E994",
					lock = "#C6A0F6",
				},
			},
			fonts = common_fonts,
		},

		gruvbox = {
			panel = {
				bg = "#282828",
				fg = "#EBDBB2",
				border = "#504945",
				accent = "#83A598",
				separator = "#665C54",
				indicator = {
					selected = "#83A598",
					occupied = "#D5C4A1",
					empty = "#665C54",
					urgent = "#FB4934",
				},
			},
			widgets = {
				battery = {
					normal = "#B8BB26",
					charging = "#83A598",
					warning = "#FABD2F",
					critical = "#FB4934",
					empty = "#665C54",
					label = "#282828",
				},
				cpu = {
					colors = {
						{ threshold = 0, color = "#A0BB20" },
						{ threshold = 25, color = "#D79921" },
						{ threshold = 55, color = "#FE8019" },
						{ threshold = 80, color = "#FB4934" },
					},
				},
				ram = {
					progress = "#83A598",
					track = "#EBDBB2",
					text = "#EBDBB2",
					track_opacity = 0.2,
				},
			},
			exit = {
				background = "#282828E6",
				foreground = "#EBDBB2",
				button_background = "#504945",
				button_hover_background = "#665C54",
				button_border = "#665C54",
				button_hover_border = "#83A598",
				actions = {
					poweroff = "#FB4934",
					reboot = "#FABD2F",
					suspend = "#83A598",
					logout = "#B8BB26",
					lock = "#D3869B",
				},
			},
			fonts = common_fonts,
		},
	},
}
