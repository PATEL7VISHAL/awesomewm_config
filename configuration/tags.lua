local awful = require('awful')
local gears = require('gears')
local icons = require('themes.icons')
local apps = require('configuration.apps')
local wibox = require("wibox")

local tags = {
    {
        icon = icons.chrome,
        type = 'chrome',
        defaultApp = apps.default.browser,
        screen = 1,
        l = awful.layout.suit.max
    },
    {
        icon = icons.code,
        type = 'code',
        defaultApp = apps.default.editor,
        screen = 1,
        l = awful.layout.suit.max
    },
    {
        icon = icons.social,
        type = 'social',
        defaultApp = apps.default.social,
        screen = 1,
        l = awful.layout.suit.tile
    },
    {
        icon = icons.game,
        type = 'game',
        defaultApp = apps.default.game,
        screen = 1,
        l = awful.layout.suit.tile
    },
    {
        icon = icons.folder,
        type = 'files',
        defaultApp = apps.default.files,
        screen = 1,
        l = awful.layout.suit.tile
    },
    {
        icon = icons.music,
        type = 'music',
        defaultApp = apps.default.music,
        screen = 1,
        l = awful.layout.suit.floating
    },
    {
        icon = icons.lab,
        type = 'any',
        defaultApp = apps.default.rofi,
        screen = 1,
        l = awful.layout.suit.tile
    }
}


awful.screen.connect_for_each_screen(
    function(s)
        for i, tag in pairs(tags) do
            awful.tag.add(
                i,
                {
                    icon = tag.icon,
                    text = i,
                    -- icon_only = true,
                    layout = tag.l,
                    gap_single_client = false,
                    -- gap = 4,
                    gap = 0,
                    screen = s,
                    defaultApp = tag.defaultApp,
                    selected = i == 1
                }
            )
        end
    end
)

-- _G.tag.connect_signal(
--     'property::layout',
--     function(t)
--         local currentLayout = awful.tag.getproperty(t, 'layout')
--         if (currentLayout == awful.layout.suit.max) then
--             t.gap = 0
--         else
--             -- t.gap = 4
--             t.gap = 1
--         end
--     end
-- )
