local awful = require("awful")
local gears = require("gears")

local M = {}

local state = {
	usage = 0,
	total_kb = 0,
	used_kb = 0,
	available_kb = 0,
	processes = {},
}

local timer

local process_running = false
local started = false
local last_process_refresh

local function read_memory()
	local file = io.open("/proc/meminfo", "r")

	if not file then
		return nil
	end

	local values = {}

	for line in file:lines() do
		local key, value = line:match("^(%w+):%s+(%d+)")

		if key and value then
			values[key] = tonumber(value)
		end
	end

	file:close()

	local total = values.MemTotal
	local available = values.MemAvailable or values.MemFree

	if not total or not available or total <= 0 then
		return nil
	end

	local used = math.max(0, total - available)
	local usage = (used / total) * 100

	return {
		usage = math.max(0, math.min(100, usage)),
		total_kb = total,
		used_kb = used,
		available_kb = available,
	}
end

local function sample()
	local memory = read_memory()

	if not memory then
		return
	end

	state.usage = memory.usage
	state.total_kb = memory.total_kb
	state.used_kb = memory.used_kb
	state.available_kb = memory.available_kb

	awesome.emit_signal("ram::update", state)
end

local function read_processes(limit)
	if process_running then
		return
	end

	process_running = true

	local command = string.format("ps -eo pid=,comm=,rss= --sort=-rss | head -n %d", limit)

	awful.spawn.easy_async_with_shell(command, function(stdout)
		process_running = false

		local processes = {}

		for line in stdout:gmatch("[^\r\n]+") do
			local pid, name, rss = line:match("^%s*(%d+)%s+(.+)%s+(%d+)%s*$")

			if pid and name and rss then
				processes[#processes + 1] = {
					pid = tonumber(pid),
					name = name,
					rss_kb = tonumber(rss),
				}
			end
		end

		state.processes = processes

		awesome.emit_signal("ram::processes", processes)
	end)
end

function M.get_state()
	return state
end

function M.refresh_processes(config)
	if process_running then
		return
	end

	local now = os.time()
	local interval = config.process_interval or 5

	if last_process_refresh and now - last_process_refresh < interval then
		return
	end

	last_process_refresh = now
	read_processes(config.process_limit or 5)
end

function M.start(config)
	if started or not config.enabled then
		return
	end

	started = true

	sample()

	timer = gears.timer({
		timeout = config.interval or 3,
		autostart = true,
		call_now = false,
		callback = sample,
	})
end

function M.stop()
	if timer then
		timer:stop()
		timer = nil
	end

	started = false
	process_running = false
	last_process_refresh = nil
end

return M
