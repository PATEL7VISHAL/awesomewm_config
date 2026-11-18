local awful = require("awful")
local gdebug = require("gears.debug")

local M = {}

local function launch(command)
    local result = awful.spawn.with_shell(command)
    if type(result) == "string" then
        gdebug.print_error("Failed to launch autostart command '" .. command .. "': " .. result)
    end
end

local function launch_if_missing(entry)
    local probe = { "pgrep", "-x", entry.process }
    local user = os.getenv("USER") or os.getenv("LOGNAME")

    if user then
        table.insert(probe, 2, "-u")
        table.insert(probe, 3, user)
    end

    awful.spawn.easy_async(probe, function(_, stderr, reason, exit_code)
        if reason == "exit" and exit_code == 0 then
            return
        end

        if reason ~= "exit" or exit_code ~= 1 then
            gdebug.print_error(
                "Failed to inspect autostart process '"
                .. entry.process
                .. "'"
                .. (stderr ~= "" and ": " .. stderr or "")
            )
            return
        end

        launch(entry.command)
    end)
end

function M.setup(apps)
    for _, entry in ipairs(apps.run_on_start_up or {}) do
        if entry.command and entry.process then
            launch_if_missing(entry)
        else
            gdebug.print_error("Invalid persistent autostart entry")
        end
    end

    for _, command in ipairs(apps.run_on_start_up_commands or {}) do
        launch(command)
    end
end

return M
