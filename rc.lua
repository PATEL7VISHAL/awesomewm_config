-- awesome_mode: api-level=4:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
require("awful.autofocus")

local settings = require("config.user")

-- Keep compatibility with existing Awesome config patterns that use globals.
terminal = settings.terminal
editor = settings.editor
editor_cmd = settings.editor_cmd
modkey = settings.modkey
altkey = settings.altkey

require("core.error_handling").setup()
require("core.theme").setup(settings)

local menu = require("ui.menu").build(settings)

require("ui.layouts").setup()
require("ui.tags").setup()
require("ui.wallpaper").setup()
require("ui.panels").setup({
	modkey = settings.modkey,
	launcher = menu.launcher,
})

require("bindings.global").setup({
	modkey = settings.modkey,
	altkey = settings.altkey,
	apps = settings.apps,
	menu = menu.main,
})
require("bindings.client").setup({
	modkey = settings.modkey,
	altkey = settings.altkey,
})

require("rules.client").setup()
require("notifications").setup()
require("signals.sloppy_focus").setup()
require("signals.client_decoration").setup()
require("core.autostart").setup(settings.apps)
