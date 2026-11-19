local awful = require("awful")
local gears = require("gears")

local M = {}

local POLL_INTERVAL = 30

local timer
local polling = false
local current_state

local BATTERY_COMMAND = [[
for battery in /sys/class/power_supply/*; do
    [ -r "$battery/type" ] || continue

    battery_type=
    [ -r "$battery/type" ] && read -r battery_type < "$battery/type"
    [ "$battery_type" = "Battery" ] || continue

    capacity=
    status=
    energy_now=
    energy_full=
    charge_now=
    charge_full=

    [ -r "$battery/capacity" ] && read -r capacity < "$battery/capacity"
    [ -r "$battery/status" ] && read -r status < "$battery/status"
    [ -r "$battery/energy_now" ] && read -r energy_now < "$battery/energy_now"
    [ -r "$battery/energy_full" ] && read -r energy_full < "$battery/energy_full"
    [ -r "$battery/charge_now" ] && read -r charge_now < "$battery/charge_now"
    [ -r "$battery/charge_full" ] && read -r charge_full < "$battery/charge_full"

    printf '%s|%s|%s|%s|%s|%s\n' \
        "$capacity" "$status" \
        "$energy_now" "$energy_full" \
        "$charge_now" "$charge_full"
done
]]

local function parse_batteries(stdout)
	local batteries = {}

	for line in stdout:gmatch("[^\r\n]+") do
		local capacity, status, energy_now, energy_full, charge_now, charge_full =
			line:match("([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)")

		capacity = tonumber(capacity)
		energy_now = tonumber(energy_now)
		energy_full = tonumber(energy_full)
		charge_now = tonumber(charge_now)
		charge_full = tonumber(charge_full)

		local now = energy_now or charge_now
		local full = energy_full or charge_full

		if not capacity and now and full and full > 0 then
			capacity = now / full * 100
		end

		if capacity then
			batteries[#batteries + 1] = {
				capacity = math.max(0, math.min(100, capacity)),
				status = status,

				energy_now = energy_now,
				energy_full = energy_full,

				charge_now = charge_now,
				charge_full = charge_full,
			}
		end
	end

	return batteries
end

local function aggregate(batteries)
	if #batteries == 0 then
		return nil
	end

	local weighted_now = 0
	local weighted_full = 0

	local capacity_sum = 0
	local charging = false
	local discharging = false
	local full = true

	for _, battery in ipairs(batteries) do
		capacity_sum = capacity_sum + battery.capacity

		local now = battery.energy_now or battery.charge_now
		local total = battery.energy_full or battery.charge_full

		if now and total and total > 0 then
			weighted_now = weighted_now + now
			weighted_full = weighted_full + total
		end

		if battery.status == "Charging" then
			charging = true
		elseif battery.status == "Discharging" then
			discharging = true
		end

		if battery.status ~= "Full" then
			full = false
		end
	end

	local percentage

	if weighted_full > 0 then
		percentage = weighted_now / weighted_full * 100
	else
		percentage = capacity_sum / #batteries
	end

	local status = "Unknown"

	if charging then
		status = "Charging"
	elseif discharging then
		status = "Discharging"
	elseif full then
		status = "Full"
	end

	return {
		percentage = math.floor(math.max(0, math.min(100, percentage)) + 0.5),

		status = status,
		charging = charging,
		discharging = discharging,
		full = full,
		battery_count = #batteries,
		batteries = batteries,
	}
end

local function refresh()
	if polling then
		return
	end

	polling = true

	awful.spawn.easy_async_with_shell(BATTERY_COMMAND, function(stdout, _, _, exit_code)
		polling = false

		if exit_code ~= 0 then
			current_state = nil
			awesome.emit_signal("battery::unavailable")
			return
		end

		local batteries = parse_batteries(stdout)
		local state = aggregate(batteries)

		if not state then
			current_state = nil
			awesome.emit_signal("battery::unavailable")
			return
		end

		current_state = state

		awesome.emit_signal("battery::update", state)
	end)
end

function M.start(interval)
	if timer then
		return
	end

	refresh()

	timer = gears.timer.start_new(interval or POLL_INTERVAL, function()
		refresh()
		return true
	end)
end

function M.refresh()
	refresh()
end

function M.get_state()
	return current_state
end

return M
