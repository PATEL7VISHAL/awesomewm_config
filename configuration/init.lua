local menubar = require("menubar")
local apps = require('configuration.apps')


-- Menubar configuration
menubar.utils.terminal = apps.default.terminal
require('configuration.layouts')
require('configuration.tags')
require('configuration.rules')

return {
    apps = apps
}
