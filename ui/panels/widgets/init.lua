-- Public widget entrypoint: panel code imports individual widgets from here.
return {
	ram = require("ui.panels.widgets.ram"),
	cpu = require("ui.panels.widgets.cpu"),
	battery = require("ui.panels.widgets.battery"),
	taglist = require("ui.panels.widgets.taglist"),
	tasklist = require("ui.panels.widgets.tasklist"),
	layoutbox = require("ui.panels.widgets.layoutbox"),
	clock = require("ui.panels.widgets.clock"),
}
