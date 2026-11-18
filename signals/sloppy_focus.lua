local M = {}

function M.setup()
    client.connect_signal("mouse::enter", function(c)
        c:activate({ context = "mouse_enter", raise = false })
    end)
end

return M
