-- awesome_mode: api-level=4:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

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
require("ui.wallpaper").setup()
require("ui.wibar").setup({
	modkey = settings.modkey,
	launcher = menu.launcher,
})

require("bindings.global").setup({
	modkey = settings.modkey,
	terminal = settings.terminal,
	menu = menu.main,
})
require("bindings.client").setup({
	modkey = settings.modkey,
	altkey = settings.altkey,
})

require("rules.client").setup()
require("ui.titlebars").setup()
require("notifications").setup()
require("signals.sloppy_focus").setup()
require("core.autostart").setup(settings.apps)
