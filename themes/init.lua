local beautiful = require('beautiful')

local gears = require('gears')

local gtk_theme = require('themes.gtk.theme')
beautiful.init(gtk_theme)
require('themes.gtk.my_panel')

-- beautiful.init(gears.filesystem.get_configuration_dir() .. "themes.theme_2")
-- require('themes.wibar2')