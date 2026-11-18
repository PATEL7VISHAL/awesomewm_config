local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
local naughty = require("naughty")
require("awful.hotkeys_popup.keys")

local M = {}

local function focus_by_index(offset)
    awful.client.focus.byidx(offset)

    if client.focus then
        client.focus:raise()
    end
end

local function restore_client()
    local c = awful.client.restore()
    if c then
        c:activate({ raise = true, context = "key.unminimize" })
    end
end

local function open_workspace_app()
    local selected_tag = awful.screen.focused().selected_tag
    if selected_tag and selected_tag.default_app then
        awful.spawn(selected_tag.default_app)
    end
end

local function toggle_notifications()
    naughty.suspended = not naughty.suspended
    naughty.notification({
        title = naughty.suspended and "Do Not Disturb enabled" or "Do Not Disturb disabled",
        timeout = 2,
        ignore_suspend = true,
    })
end

function M.setup(opts)
    local modkey = opts.modkey
    local altkey = opts.altkey
    local apps = opts.apps.default

    awful.mouse.append_global_mousebindings({
        awful.button({}, 3, function() opts.menu:toggle() end),
        awful.button({}, 4, awful.tag.viewprev),
        awful.button({}, 5, awful.tag.viewnext),
    })

    awful.keyboard.append_global_keybindings({
        awful.key({ modkey }, "F12", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
        awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
        awful.key({ modkey, "Shift" }, "d", toggle_notifications, { description = "toggle Do Not Disturb", group = "notifications" }),
        awful.key({ modkey, "Shift" }, ";", function()
            naughty.destroy_all_notifications(nil, "clear screen")
        end, { description = "clear notifications", group = "notifications" }),

        awful.key({ modkey }, "w", awful.tag.viewprev, { description = "view previous", group = "tag" }),
        awful.key({ modkey }, "s", awful.tag.viewnext, { description = "view next", group = "tag" }),
        awful.key({ altkey, "Control" }, "Up", awful.tag.viewprev, { description = "view previous", group = "tag" }),
        awful.key({ altkey, "Control" }, "Down", awful.tag.viewnext, { description = "view next", group = "tag" }),
        awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),

        awful.key({ modkey }, "d", function() focus_by_index(1) end, { description = "focus next client", group = "client" }),
        awful.key({ modkey }, "a", function() focus_by_index(-1) end, { description = "focus previous client", group = "client" }),
        awful.key({ altkey }, "Tab", function() focus_by_index(1) end, { description = "switch to next client", group = "client" }),
        awful.key({ altkey, "Shift" }, "Tab", function() focus_by_index(-1) end, { description = "switch to previous client", group = "client" }),
        awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
        awful.key({ modkey, "Control" }, "n", restore_client, { description = "restore minimized", group = "client" }),
        awful.key({ modkey }, "o", function()
            if client.focus then
                client.focus:move_to_screen()
            end
        end, { description = "move client to next screen", group = "client" }),

        awful.key({ modkey }, "r", function()
            awful.spawn(apps.rofi)
        end, { description = "open application launcher", group = "launcher" }),
        awful.key({ altkey }, "space", function()
            awful.spawn("rofi -combi-modi window,drun -show combi -modi combi")
        end, { description = "open combined launcher", group = "launcher" }),
        awful.key({ modkey }, "x", function() awful.spawn(apps.terminal) end, { description = "open terminal", group = "launcher" }),
        awful.key({ modkey }, "c", function() awful.spawn(apps.editor) end, { description = "open GUI editor", group = "launcher" }),
        awful.key({ modkey, "Shift" }, "c", function() awful.spawn(apps.editor2) end, { description = "open terminal editor", group = "launcher" }),
        awful.key({ modkey }, "b", function() awful.spawn(apps.browser) end, { description = "open primary browser", group = "launcher" }),
        awful.key({ modkey, "Shift" }, "b", function() awful.spawn(apps.browser2) end, { description = "open secondary browser", group = "launcher" }),
        awful.key({ modkey }, "e", function() awful.spawn(apps.files) end, { description = "open file manager", group = "launcher" }),
        awful.key({ modkey, "Shift" }, "e", function() awful.spawn(apps.tfiles) end, { description = "open terminal file manager", group = "launcher" }),
        awful.key({ modkey }, "m", function() awful.spawn("xfce4-taskmanager") end, { description = "open system monitor", group = "launcher" }),
        awful.key({ modkey }, "t", open_workspace_app, { description = "open workspace application", group = "tag" }),
        awful.key({ modkey, "Control" }, "c", function()
            awful.spawn.with_shell("$HOME/.config/rofi/scripts/quickConfigEdit")
        end, { description = "edit config", group = "launcher" }),
        awful.key({ modkey, "Control" }, "p", function()
            awful.spawn.with_shell("$HOME/.config/rofi/scripts/quickEdit")
        end, { description = "edit project", group = "launcher" }),

        awful.key({ modkey }, "p", function()
            awful.spawn.with_shell(apps.screenshot)
        end, { description = "take screenshot", group = "screenshots" }),
        awful.key({ modkey, "Shift" }, "p", function()
            awful.spawn.with_shell(apps.region_screenshot)
        end, { description = "take region screenshot", group = "screenshots" }),

        awful.key({ altkey, "Shift" }, "Right", function() awful.tag.incmwfact(0.05) end, { description = "increase master width", group = "layout" }),
        awful.key({ altkey, "Shift" }, "Left", function() awful.tag.incmwfact(-0.05) end, { description = "decrease master width", group = "layout" }),
        awful.key({ altkey, "Shift" }, "Down", function() awful.client.incwfact(0.05) end, { description = "decrease master height", group = "layout" }),
        awful.key({ altkey, "Shift" }, "Up", function() awful.client.incwfact(-0.05) end, { description = "increase master height", group = "layout" }),
        awful.key({ modkey, "Shift" }, "Left", function() awful.tag.incnmaster(1, nil, true) end, { description = "increase master clients", group = "layout" }),
        awful.key({ modkey, "Shift" }, "Right", function() awful.tag.incnmaster(-1, nil, true) end, { description = "decrease master clients", group = "layout" }),
        awful.key({ modkey, "Control" }, "Left", function() awful.tag.incncol(1, nil, true) end, { description = "increase columns", group = "layout" }),
        awful.key({ modkey, "Control" }, "Right", function() awful.tag.incncol(-1, nil, true) end, { description = "decrease columns", group = "layout" }),
        awful.key({ modkey }, "space", function() awful.layout.inc(1) end, { description = "select next layout", group = "layout" }),
        awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end, { description = "select previous layout", group = "layout" }),

        awful.key({}, "XF86MonBrightnessUp", function() awful.spawn("light -A 5") end, { description = "increase brightness", group = "hardware" }),
        awful.key({}, "XF86MonBrightnessDown", function() awful.spawn("light -U 5") end, { description = "decrease brightness", group = "hardware" }),
        awful.key({}, "XF86AudioRaiseVolume", function() awful.spawn("amixer -D pulse sset Master 5%+") end, { description = "increase volume", group = "hardware" }),
        awful.key({}, "XF86AudioLowerVolume", function() awful.spawn("amixer -D pulse sset Master 5%-") end, { description = "decrease volume", group = "hardware" }),
        awful.key({}, "XF86AudioMute", function() awful.spawn("amixer -D pulse set Master 1+ toggle") end, { description = "toggle mute", group = "hardware" }),
        awful.key({}, "XF86AudioPlay", function() awful.spawn("playerctl play-pause") end, { description = "play or pause media", group = "hardware" }),
        awful.key({}, "XF86AudioNext", function() awful.spawn("playerctl next") end, { description = "next media", group = "hardware" }),
        awful.key({}, "XF86AudioPrev", function() awful.spawn("playerctl previous") end, { description = "previous media", group = "hardware" }),
        awful.key({ modkey }, "l", function()
            awful.spawn("xdotool key --clearmodifiers Right")
        end, { description = "send right arrow", group = "custom" }),
    })

    awful.keyboard.append_global_keybindings({
        awful.key({
            modifiers = { modkey },
            keygroup = "numrow",
            description = "view workspace",
            group = "tag",
            on_press = function(index)
                local t = awful.screen.focused().tags[index]
                if t then
                    t:view_only()
                end
            end,
        }),
        awful.key({
            modifiers = { modkey, "Control" },
            keygroup = "numrow",
            description = "toggle workspace",
            group = "tag",
            on_press = function(index)
                local t = awful.screen.focused().tags[index]
                if t then
                    awful.tag.viewtoggle(t)
                end
            end,
        }),
        awful.key({
            modifiers = { modkey, "Shift" },
            keygroup = "numrow",
            description = "move client to workspace",
            group = "tag",
            on_press = function(index)
                if client.focus then
                    local t = client.focus.screen.tags[index]
                    if t then
                        client.focus:move_to_tag(t)
                    end
                end
            end,
        }),
        awful.key({
            modifiers = { modkey, "Control", "Shift" },
            keygroup = "numrow",
            description = "toggle client workspace",
            group = "tag",
            on_press = function(index)
                if client.focus then
                    local t = client.focus.screen.tags[index]
                    if t then
                        client.focus:toggle_tag(t)
                    end
                end
            end,
        }),
    })
end

return M
