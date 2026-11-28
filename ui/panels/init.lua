local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")
local panel_config = require("config.panel")
local widgets = require("ui.panels.widgets")
local tooltip = require("ui.tooltip")

local M = {}

local function with_vertical_spacing(widget, spacing)
	return wibox.container.margin(
		widget,
		0, -- left
		0, -- right
		spacing, -- top
		spacing -- bottom
	)
end

local function create_panel(s, opts, launcher)
	local panel = awful.wibar({
		screen = s,
		position = opts.position,
		width = s.geometry.width,
		height = opts.height,
		bg = beautiful.panel_bg or beautiful.bg_normal,
		fg = beautiful.panel_fg or beautiful.fg_normal,
	})

	panel:setup({
		{
			{
				{
					widgets.taglist(s, {
						modkey = opts.modkey,
						margin = opts.margin,
						spacing = opts.spacing,
						style = opts.workspace_style,
					}),
					with_vertical_spacing({
						forced_width = 1,
						color = beautiful.panel_separator,
						widget = wibox.widget.separator,
					}, 6),
					widgets.layoutbox(s, { maring = opts.margin, spacing = opts.spacing }),
					{
						{
							forced_width = 1,
							color = beautiful.panel_separator,
							widget = wibox.widget.separator,
						},
						top = 6,
						bottom = 6,
						left = opts.spacing,
						right = opts.spacing,
						widget = wibox.container.margin,
					},
					widgets.tasklist.new(s, opts),
					spacing = opts.spacing,
					layout = wibox.layout.fixed.horizontal,
				},
				{
					widgets.clock.new(s, opts.clock_format, opts),
					-- launcher,
					spacing = opts.spacing,
					layout = wibox.layout.fixed.horizontal,
				},
				{
					with_vertical_spacing(widgets.cpu.new(), 1),
					with_vertical_spacing(widgets.network.new(), 1),
					with_vertical_spacing(widgets.ram.new(), 1),
					widgets.battery.new(),
					awful.widget.keyboardlayout(),
					widgets.systray.new(),
					widgets.power_menu.new(s, opts),
					spacing = opts.spacing * 2,
					layout = wibox.layout.fixed.horizontal,
				},
				expand = "none",
				layout = wibox.layout.align.horizontal,
			},
			-- left = opts.margin,
			-- right = opts.margin,
			widget = wibox.container.margin,
		},
		shape = gears.shape.rectangle,
		widget = wibox.container.background,
	})

	return panel
end

---@param opts PanelOptions
function M.setup(opts)
	local style = os.getenv("AWESOME_PANEL_STYLE") or panel_config.style
	local preset = panel_config.presets[style]
	if not preset then
		error("Unknown panel style '" .. tostring(style) .. "'")
	end

	tooltip.set_panel_position(preset.position)

	screen.connect_signal("request::desktop_decoration", function(s)
		require("ui.tags").create_for_screen(s)

		local panel_opts = gears.table.crush({}, preset)
		panel_opts.modkey = opts.modkey
		s.panel = create_panel(s, panel_opts, opts.launcher)
		s.mywibox = s.panel
	end)

	local function update_visibility(screen)
		if not screen or not screen.valid or not screen.panel then
			return
		end

		local has_fullscreen = false
		for _, candidate in ipairs(screen.clients) do
			if candidate.fullscreen and candidate:isvisible() then
				has_fullscreen = true
				break
			end
		end

		screen.panel.visible = not has_fullscreen
	end

	client.connect_signal("property::fullscreen", function(c)
		update_visibility(c.screen)
	end)
	client.connect_signal("property::minimized", function(c)
		update_visibility(c.screen)
	end)
	client.connect_signal("property::screen", function(c, previous_screen)
		update_visibility(previous_screen)
		update_visibility(c.screen)
	end)
	client.connect_signal("request::manage", function(c)
		gears.timer.delayed_call(function()
			update_visibility(c.screen)
		end)
	end)
	client.connect_signal("request::unmanage", function(c)
		local screen = c.screen
		gears.timer.delayed_call(function()
			update_visibility(screen)
		end)
	end)
end

return M
