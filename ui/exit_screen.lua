local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local icons = require("theme.icons")
local apps = require("config.apps")

local config = require("config.exit_screen")
local theme = beautiful.exit_theme

local clickable_container = require("ui.panels.widgets.lib.clickable_container")

local dpi = beautiful.xresources.apply_dpi

local M = {}

local exit_screen
local keygrabber

local function hide()
	if keygrabber then
		keygrabber:stop()
		keygrabber = nil
	end

	if exit_screen then
		exit_screen.visible = false
	end
end

local function logout()
	hide()
	awesome.quit()
end

local function lock()
	hide()

	local lock_command = config.lock_command or (apps.default and apps.default.lock) or "loginctl lock-session"

	awful.spawn.with_shell("sleep 0.2 && " .. lock_command)
end

local function suspend()
	hide()

	local lock_command = config.lock_command or (apps.default and apps.default.lock) or "loginctl lock-session"

	local suspend_command = config.commands.suspend or "systemctl suspend"

	-- Start the locker before suspending.
	awful.spawn.with_shell(lock_command .. " & sleep 1; " .. suspend_command)
end

local function poweroff()
	hide()

	awful.spawn.with_shell(config.commands.poweroff or "poweroff")
end

local function reboot()
	hide()

	awful.spawn.with_shell(config.commands.reboot or "reboot")
end

local actions = {
	{
		name = "Shutdown",
		icon = icons.power,
		shortcut = "poweroff",
		callback = poweroff,
	},
	{
		name = "Restart",
		icon = icons.restart,
		shortcut = "reboot",
		callback = reboot,
	},
	{
		name = "Sleep",
		icon = icons.sleep,
		shortcut = "suspend",
		callback = suspend,
	},
	{
		name = "Logout",
		icon = icons.logout,
		shortcut = "logout",
		callback = logout,
	},
	{
		name = "Lock",
		icon = icons.lock,
		shortcut = "lock",
		callback = lock,
	},
}

local function create_button(action)
	local icon_color = theme.actions[action.shortcut]
	local icon = wibox.widget.imagebox(gears.color.recolor_image(action.icon, icon_color))
	icon.resize = true
	icon.forced_width = config.icon_size
	icon.forced_height = config.icon_size

	local icon_margin =
		wibox.container.margin(icon, config.icon_padding, config.icon_padding, config.icon_padding, config.icon_padding)

	local button = clickable_container.new(icon_margin, {
		width = dpi(config.button_size),
		height = dpi(config.button_size),

		background = theme.button_background,
		hover_background = theme.button_hover_background,

		border_color = theme.button_border,
		hover_border = theme.button_hover_border,

		shape = gears.shape.circle,

		on_click = action.callback,
	})

	local label = wibox.widget.textbox()

	label.align = "center"
	label.valign = "center"

	label.font = config.label_font or beautiful.font or "sans 11"

	label:set_markup(
		string.format('<span foreground="%s" size="%dpt">%s</span>', theme.foreground, config.label_size, action.name)
	)

	local item = wibox.layout.fixed.vertical()

	item.spacing = config.label_spacing

	item:add(button)
	item:add(label)

	return item
end

local function create_content()
	local row = wibox.layout.fixed.horizontal()

	row.spacing = dpi(config.button_spacing)

	for _, action in ipairs(actions) do
		row:add(create_button(action))
	end

	return {
		nil,
		{
			nil,
			row,
			nil,
			expand = "none",
			layout = wibox.layout.align.horizontal,
		},
		nil,
		expand = "none",
		layout = wibox.layout.align.vertical,
	}
end

local function create_overlay(screen)
	local geometry = screen.geometry

	local overlay = wibox({
		screen = screen,

		x = geometry.x,
		y = geometry.y,

		width = geometry.width,
		height = geometry.height,

		visible = false,
		ontop = true,
		type = "splash",
	})

	overlay.bg = theme.background
	overlay.fg = theme.foreground

	overlay:setup(create_content())

	overlay:buttons(gears.table.join(
		-- Middle click closes the overlay.
		awful.button({}, 2, hide),

		-- Right click closes the overlay.
		awful.button({}, 3, hide)
	))

	return overlay
end

local function handle_key(_, modifiers, key)
	key = key:lower()

	local shortcuts = config.shortcuts

	if key == shortcuts.poweroff:lower() then
		poweroff()
	elseif key == shortcuts.reboot:lower() then
		reboot()
	elseif key == shortcuts.suspend:lower() then
		suspend()
	elseif key == shortcuts.logout:lower() then
		logout()
	elseif key == shortcuts.lock:lower() then
		lock()
	elseif key == "escape" or key == "q" or key == "x" then
		hide()
	end
end

function M.show()
	if not config.enabled then
		return
	end

	local screen = awful.screen.focused()

	if not exit_screen or exit_screen.screen ~= screen then
		if exit_screen then
			exit_screen.visible = false
		end

		exit_screen = create_overlay(screen)
	end

	exit_screen.visible = true

	if keygrabber then
		keygrabber:stop()
	end

	keygrabber = awful.keygrabber({
		keypressed_callback = handle_key,
	})

	keygrabber:start()
end

function M.hide()
	hide()
end

function M.toggle()
	if exit_screen and exit_screen.visible then
		hide()
	else
		M.show()
	end
end

return M
