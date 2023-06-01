-- MODULE AUTO-START
-- Run all the apps listed in configuration/apps.lua as run_on_start_up only once when awesome start

local awful = require('awful')
local apps = require('configuration.apps')
local log = require('module.log')

for _, app in ipairs(apps.run_on_start_up) do
  local process_name = app 
  local i = app:find(' ')
  if i then
    process_name = app:sub(0, (i - 1))
  end

  awful.spawn.with_shell('pkill ' .. process_name)
end

os.execute("sleep " .. tonumber(0.3))

for _, app in ipairs(apps.run_on_start_up) do
  awful.spawn.with_shell(app)
end

-- local function run_once(cmd)
  -- local process_name = cmd
  -- local i = cmd:find(' ')
  -- if i then
  --   process_name = cmd:sub(0, (i - 1))
  -- end

  -- awful.spawn.with_shell('pkill ' .. process_name)
  -- awful.spawn.with_shell(cmd .. " &")
  -- awful.spawn.with_shell(cmd)

  -- log(process_name)
  -- log(cmd)
-- end

