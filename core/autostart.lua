local awful = require("awful")
local gears = require("gears")
local gdebug = require("gears.debug")

local M = {}

local function launch(command)
    local result = awful.spawn.with_shell(command)
    if type(result) == "string" then
        gdebug.print_error("Failed to launch autostart command '" .. command .. "': " .. result)
    end
end

local function executable_name(command_line)
    local executable = command_line and command_line:match("^%s*(%S+)")
    if not executable then
        return nil
    end

    return executable:match("([^/]+)$")
end

local function running_processes(stdout)
    local processes = {}

    for line in stdout:gmatch("[^\r\n]+") do
        local comm, args = line:match("^%s*(%S+)%s+(.+)$")
        if comm and args then
            processes[#processes + 1] = {
                comm = comm,
                executable = executable_name(args),
            }
        end
    end

    return processes
end

local function is_running(process, processes)
    for _, running in ipairs(processes) do
        if running.comm == process or running.executable == process then
            return true
        end
    end

    return false
end

local function launch_missing(entries)
    local user = os.getenv("USER") or os.getenv("LOGNAME")
    local probe = user
        and { "ps", "-u", user, "-o", "comm=,args=" }
        or { "ps", "-e", "-o", "comm=,args=" }

    awful.spawn.easy_async(probe, function(stdout, stderr, reason, exit_code)
        if reason ~= "exit" or exit_code ~= 0 then
            gdebug.print_error(
                "Failed to inspect autostart processes"
                .. (stderr ~= "" and ": " .. stderr or "")
            )
            return
        end

        local processes = running_processes(stdout)

        for _, entry in ipairs(entries) do
            if not is_running(entry.process, processes) then
                launch(entry.command)
            end
        end
    end)
end

function M.setup(apps)
    -- Let Awesome complete the first event loop before starting optional
    -- session services and shell commands.
    gears.timer.start_new(1, function()
        local entries = {}

        for _, entry in ipairs(apps.run_on_start_up or {}) do
            if entry.command and entry.process then
                entries[#entries + 1] = entry
            else
                gdebug.print_error("Invalid persistent autostart entry")
            end
        end

        launch_missing(entries)

        for _, command in ipairs(apps.run_on_start_up_commands or {}) do
            launch(command)
        end

        return false
    end)
end

return M
