-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")


require("awful.autofocus")

require("awful.hotkeys_popup.keys")

require('module.errors-handling')



require('module.auto-start')
require('configuration')
require('themes')

-- require('module.new-client-appears')
