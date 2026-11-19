-- Public widget entrypoint: panel code imports individual widgets from here.
return {
	taglist = require("ui.panels.widgets.taglist"),
	tasklist = require("ui.panels.widgets.tasklist"),
	layoutbox = require("ui.panels.widgets.layoutbox"),
	clock = require("ui.panels.widgets.clock"),
}
