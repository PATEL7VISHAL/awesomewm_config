local filesystem = require("gears.filesystem")

-- Thanks to jo148 on github for making rofi dpi aware!
local with_dpi = require("beautiful").xresources.apply_dpi
local get_dpi = require("beautiful").xresources.get_dpi
local rofi_command = "env /usr/bin/rofi -dpi "
	.. get_dpi()
	.. " -width "
	.. with_dpi(400)
	.. " -show drun -theme "
	.. filesystem.get_configuration_dir()
	.. "/themes/rofi.rasi -run-command \"/bin/bash -c -i 'shopt -s expand_aliases; {cmd}'\""

local launcher_command = "/home/vc/.config/leftwm/launcher/launcher.sh"

return {
	-- List of apps to start by default on some actions
	default = {
		terminal = "alacritty",
		rofi = rofi_command,
		launcher = launcher_command,
		lock = "i3lock-fancy",
		quake = "alacritty",
		screenshot = "flameshot screen -p /home/vc/Pictures/screenshot/etc",
		region_screenshot = "flameshot gui -p ~/Pictures",
		delayed_screenshot = "flameshot screen -p ~/Pictures -d 5000",
		-- browser = 'brave-browser',
		browser = "brave",
		-- browser = "firefox",
		-- browser = "waterfox",
		editor = "codium", -- gui text editor
		--social = 'discord',
		game = rofi_command,
		files = "pcmanfm",
		-- music = rofi_command,
		music = "vlc",
	},
	-- List of apps to start once on start-up
	run_on_start_up = {
		"nitrogen --restore",
		"picom --config /home/vc/.config/picom/picom.conf",
		"nm-applet --indicator", -- wifi
		"blueman-applet",
		"pnmixer", -- shows an audiocontrol applet in systray when installed.
		"numlockx on", -- enable numlock
		"xfce4-power-manager", -- Power manager
		"flameshot",
		-- '~/.config/awesome/configuration/awspawn', -- Spawn "dirty" apps that can linger between sessions
	},
}
