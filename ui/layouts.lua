local awful = require("awful")

local M = {}

function M.setup()
    tag.connect_signal("request::default_layouts", function()
        awful.layout.append_default_layouts({
            awful.layout.suit.tile,
            awful.layout.suit.max,
            awful.layout.suit.floating,
        })
    end)
end

return M
