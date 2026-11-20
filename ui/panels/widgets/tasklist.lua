local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local config = require("config.tasklist")

local M = {}

local function ordered_clients(s)
	local clients = {}

	for _, c in ipairs(client.get()) do
		if c.valid and c.screen == s and not c.skip_taskbar then
			clients[#clients + 1] = c
		end
	end

	table.sort(clients, function(a, b)
		local a_tag = a.first_tag and a.first_tag.index or 0
		local b_tag = b.first_tag and b.first_tag.index or 0

		if a_tag ~= b_tag then
			return a_tag < b_tag
		end

		return (a.window or 0) < (b.window or 0)
	end)

	return clients
end

local function activate_client(c)
	if not c or not c.valid then
		return
	end

	if c.first_tag then
		c.first_tag:view_only()
	end

	if c.minimized then
		c.minimized = false
	end

	c:activate({
		context = "tasklist",
		raise = true,
	})
end

local function buttons()
	return gears.table.join(
		awful.button({}, 1, function(c)
			activate_client(c)
		end),

		awful.button({}, 2, function(c)
			if c and c.valid then
				c:kill()
			end
		end),

		awful.button({}, 3, function()
			awful.menu.client_list({ theme = { width = beautiful.menu_width or 260 } })
		end),

		awful.button({}, 4, function()
			awful.client.focus.byidx(-1)
		end),

		awful.button({}, 5, function()
			awful.client.focus.byidx(1)
		end)
	)
end

local function update_indicator(self, c)
	local indicators = self:get_children_by_id("status_dot")
	local indicator = indicators[1]

	if not indicator then
		return
	end

	if c.urgent then
		indicator.bg = config.colors.urgent
		indicator.visible = true
	elseif client.focus == c then
		indicator.bg = config.colors.focused
		indicator.visible = true
	else
		indicator.visible = false
	end
end

function M.new(s, opts)
	-- One tooltip for all tasks; per-task tooltips each create a wibox.
	local shared_tooltip_target
	local shared_tooltip = awful.tooltip({
		mode = "outside",
		preferred_positions = opts and opts.position == "bottom" and { "top" } or { "bottom" },
		timer_function = function()
			local task_client = shared_tooltip_target and shared_tooltip_target._task_client
			return task_client and task_client.valid
				and (task_client.name or task_client.class or "Window")
				or ""
		end,
	})

	local tasklist = awful.widget.tasklist({
		screen = s,

		filter = awful.widget.tasklist.filter.allscreen,

		source = function(task_screen)
			return ordered_clients(task_screen)
		end,

		buttons = buttons(),

		disable_task_name = true,

		base_layout = {
			spacing = config.spacing,
			layout = wibox.layout.fixed.horizontal,
		},

		widget_template = {
			{
				{
					-- Application icon
					{
						{
							id = "icon_role",
							resize = true,
							widget = wibox.widget.imagebox,
						},

						forced_width = config.icon_size,
						forced_height = config.icon_size,
						widget = wibox.container.place,
					},

					-- Status dot overlay
					{
						{
							{
								id = "status_dot",
								forced_width = config.dot_size,
								forced_height = config.dot_size,
								shape = gears.shape.circle,
								visible = false,
								widget = wibox.container.background,
							},

							halign = "center",
							valign = "bottom",
							fill_horizontal = true,
							fill_vertical = true,
							widget = wibox.container.place,
						},

						widget = wibox.container.background,
					},

					layout = wibox.layout.stack,
				},

				margins = config.icon_padding,
				widget = wibox.container.margin,
			},

			forced_width = config.item_size,
			forced_height = config.item_size,
			bg = beautiful.panel_bg or beautiful.bg_normal or "#00000000",
			shape = gears.shape.rounded_bar,
			widget = wibox.container.background,

			create_callback = function(self, c)
				self._task_client = c
				self:connect_signal("mouse::enter", function()
					shared_tooltip_target = self
				end)
				shared_tooltip:add_to_object(self)
				update_indicator(self, c)
			end,

			update_callback = function(self, c)
				self._task_client = c
				update_indicator(self, c)
			end,
		},
	})

	s.mytasklist = tasklist

	return tasklist
end

return M
