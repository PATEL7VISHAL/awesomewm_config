local beautiful = require("beautiful")

local M = {}

function M.setup(settings)
    beautiful.init(settings.theme)
end

return M
