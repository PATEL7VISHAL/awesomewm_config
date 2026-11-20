local awful = require("awful")
local gdebug = require("gears.debug")

local M = {}

local function process_probe(process, user)
	local pattern = process

	-- Linux limits the comm name used by `pgrep -x` to 15 characters.
	-- Match the executable name in the full command line for longer names.
	if #process > 15 then
		pattern = "(^|/)" .. process .. "($|[[:space:]])"

		if user then
			return { "pgrep", "-f", "-u", user, pattern }
		end

		return { "pgrep", "-f", pattern }
	end

	if user then
		return { "pgrep", "-x", "-u", user, process }
	end

	return { "pgrep", "-x", process }
end

local function launch(command)
    local result = awful.spawn.with_shell(command)
    if type(result) == "string" then
        gdebug.print_error("Failed to launch autostart command '" .. command .. "': " .. result)
    end
end

local function launch_if_missing(entry)
    local user = os.getenv("USER") or os.getenv("LOGNAME")
    local probe = process_probe(entry.process, user)

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
