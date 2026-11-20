local awful = require("awful")
local gears = require("gears")

local M = {}

local state = {
	usage = 0,
	model = "Unknown CPU",
	processes = {},
}

local previous_total
local previous_idle

local cpu_timer

local process_running = false
local started = false
local last_process_refresh

local function read_cpu_info()
	local file = io.open("/proc/cpuinfo", "r")

	if not file then
		return "Unknown CPU"
	end

	local model = "Unknown CPU"

	for line in file:lines() do
		local value = line:match("^model name%s*:%s*(.+)") or line:match("^Hardware%s*:%s*(.+)")

		if value then
			model = value
			break
		end
	end

	file:close()

	return model
end

local function read_cpu_usage()
	local file = io.open("/proc/stat", "r")

	if not file then
		return nil
	end

	local line = file:read("*l")
	file:close()

	if not line then
		return nil
	end

	local values = {}

	for value in line:gmatch("%d+") do
		values[#values + 1] = tonumber(value)
	end

	if #values < 4 then
		return nil
	end

	-- user + nice + system + idle + iowait
	-- + irq + softirq + steal
	local total = 0

	for i = 1, math.min(#values, 8) do
		total = total + values[i]
	end

	local idle = values[4] + (values[5] or 0)

	if previous_total == nil then
		previous_total = total
		previous_idle = idle
		return 0
	end

	local total_delta = total - previous_total
	local idle_delta = idle - previous_idle

	previous_total = total
	previous_idle = idle

	if total_delta <= 0 then
		return nil
	end

	local usage = (total_delta - idle_delta) / total_delta * 100

	return math.max(0, math.min(100, usage))
end

local function read_processes(limit)
	if process_running then
		return
	end

	process_running = true

	local command = string.format("ps -eo pid=,comm=,pcpu= --sort=-pcpu | head -n %d", limit)

	awful.spawn.easy_async_with_shell(command, function(stdout)
		process_running = false

		local processes = {}

		for line in stdout:gmatch("[^\r\n]+") do
			local pid, name, usage = line:match("^%s*(%d+)%s+(.+)%s+([%d%.]+)%s*$")

			if pid and name and usage then
				processes[#processes + 1] = {
					pid = tonumber(pid),
					name = name,
					usage = tonumber(usage),
				}
			end
		end

		state.processes = processes

		awesome.emit_signal("cpu::processes", processes)
	end)
end

function M.get_state()
	return state
end

function M.refresh_processes(config)
	local process_config = config.processes or {}
	if not process_config.enabled or process_running then
		return
	end

	local now = os.time()
	local interval = process_config.interval or 5

	if last_process_refresh and now - last_process_refresh < interval then
		return
	end

	last_process_refresh = now
	read_processes(process_config.limit or 5)
end

function M.start(config)
	if started or not config.enabled then
		return
	end

	started = true

	state.model = read_cpu_info()

	local function sample()
		local usage = read_cpu_usage()

		if usage == nil then
			return
		end

		state.usage = usage

		awesome.emit_signal("cpu::update", usage)
	end

	sample()

	cpu_timer = gears.timer({
		timeout = config.interval or 1,
		autostart = true,
		call_now = false,
		callback = sample,
	})
end

function M.stop()
	if cpu_timer then
		cpu_timer:stop()
		cpu_timer = nil
	end

	started = false
	process_running = false
	last_process_refresh = nil

	previous_total = nil
	previous_idle = nil
end

return M
