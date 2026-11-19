local awful = require("awful")
local apps = require("config.apps")
local icons = require("theme.icons")

---@type WorkspaceDefinition[]
return {
    {
        name = "chrome",
        type = "browser",
        icon = icons.chrome,
        default_app = apps.default.browser,
        layout = awful.layout.suit.max,
    },
    {
        name = "code",
        type = "code",
        icon = icons.code,
        default_app = apps.default.editor,
        layout = awful.layout.suit.max,
    },
    {
        name = "social",
        type = "social",
        icon = icons.social,
        default_app = apps.default.social,
        layout = awful.layout.suit.tile,
    },
    {
        name = "music",
        type = "music",
        icon = icons.music,
        default_app = apps.default.music,
        layout = awful.layout.suit.tile,
    },
    {
        name = "lab",
        type = "utility",
        icon = icons.lab,
        default_app = apps.default.rofi,
        layout = awful.layout.suit.tile,
    },
}
