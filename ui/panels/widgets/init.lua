-- Public widget entrypoint: panel code imports individual widgets from here.
return {
	taglist = require("ui.panels.widgets.taglist"),
	tasklist = require("ui.panels.widgets.tasklist"),
	clock = require("ui.panels.widgets.clock"),
	network = require("ui.panels.widgets.network"),
	cpu = require("ui.panels.widgets.cpu"),
	ram = require("ui.panels.widgets.ram"),
	battery = require("ui.panels.widgets.battery"),
	systray = require("ui.panels.widgets.systray"),
	layoutbox = require("ui.panels.widgets.layoutbox"),
	power_menu = require("ui.panels.widgets.power_menu"),
}
