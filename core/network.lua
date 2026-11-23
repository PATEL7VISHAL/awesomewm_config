local gears = require("gears")

local M = {}

local state = {
	download = 0,
	upload = 0,
	interface = nil,
}

local previous_interface
local previous_rx
local previous_tx
local timer
local started = false
local last_sample
local next_detection = 0

local function read_counter(path)
	local file = io.open(path, "r")

	if not file then
		return nil
	end

	local value = tonumber(file:read("*a"))
	file:close()

	return value
end

-- Monotonic sub-second clock as a plain Lua number.
local function read_uptime()
	local file = io.open("/proc/uptime", "r")

	if not file then
		return nil
	end

	local value = tonumber(file:read("*l"):match("^(%S+)"))
	file:close()

	return value
end

local function detect_interface(config)
	if config.interface then
		return config.interface
	end

	local file = io.open("/proc/net/route", "r")

	if not file then
		return nil
	end

	local selected_interface
	local selected_metric

	for line in file:lines() do
		local interface, destination, _, flags, _, _, metric =
			line:match("^(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)")

		local route_flags = tonumber(flags, 16)
		local route_metric = tonumber(metric)

		if destination == "00000000"
			and route_flags
			and route_flags % 2 == 1
			and route_metric
			and (not selected_metric or route_metric < selected_metric)
		then
			selected_interface = interface
			selected_metric = route_metric
		end
	end

	file:close()

	return selected_interface
end

local function read_stats(interface)
	if not interface or not interface:match("^[%w_.:%-]+$") then
		return nil, nil
	end

	local path = "/sys/class/net/" .. interface .. "/statistics/"

	return read_counter(path .. "rx_bytes"), read_counter(path .. "tx_bytes")
end

local function publish(download, upload)
	state.download = download
	state.upload = upload

	awesome.emit_signal("network::update", state)
end

local function sample(config)
	local now = read_uptime()

	if not now then
		publish(0, 0)
		return
	end

	if now >= next_detection then
		local interface = detect_interface(config)

		if interface ~= previous_interface then
			previous_interface = interface
			previous_rx = nil
			previous_tx = nil
		end

		state.interface = interface
		next_detection = now + (config.interface_detection_interval or 5)
	end

	local rx, tx = read_stats(previous_interface)

	if not rx or not tx then
		previous_rx = nil
		previous_tx = nil
		last_sample = now
		publish(0, 0)
		return
	end

	local elapsed = last_sample and now - last_sample or 0
	local download = 0
	local upload = 0

	if previous_rx and previous_tx and elapsed > 0 then
		local rx_delta = rx - previous_rx
		local tx_delta = tx - previous_tx

		if rx_delta >= 0 then
			download = rx_delta / elapsed
		end

		if tx_delta >= 0 then
			upload = tx_delta / elapsed
		end
	end

	previous_rx = rx
	previous_tx = tx
	last_sample = now
	publish(download, upload)
end

function M.get_state()
	return state
end

function M.start(config)
	if started or not config.enabled then
		return
	end

	started = true
	next_detection = 0
	last_sample = nil
	sample(config)

	timer = gears.timer({
		timeout = config.sampling_interval or 1,
		autostart = true,
		call_now = false,
		callback = function()
			sample(config)
		end,
	})
end

function M.stop()
	if timer then
		timer:stop()
		timer = nil
	end

	started = false
	previous_interface = nil
	previous_rx = nil
	previous_tx = nil
	last_sample = nil
	next_detection = 0
end

return M
