local awful = require("awful")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

local M = {}

function M.setup(opts)
    awful.mouse.append_global_mousebindings({
        awful.button({}, 3, function() opts.menu:toggle() end),
        awful.button({}, 4, awful.tag.viewprev),
        awful.button({}, 5, awful.tag.viewnext),
    })

    awful.keyboard.append_global_keybindings({
        awful.key({ opts.modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
        awful.key({ opts.modkey }, "w", function() opts.menu:show() end, { description = "show main menu", group = "awesome" }),
        awful.key({ opts.modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
        awful.key({ opts.modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
        awful.key({ opts.modkey }, "x", function()
            awful.prompt.run({
                prompt = "Run Lua code: ",
                textbox = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval",
            })
        end, { description = "lua execute prompt", group = "awesome" }),
        awful.key({ opts.modkey }, "Return", function() awful.spawn(opts.terminal) end, { description = "open a terminal", group = "launcher" }),
        awful.key({ opts.modkey }, "r", function() awful.screen.focused().mypromptbox:run() end, { description = "run prompt", group = "launcher" }),
        awful.key({ opts.modkey }, "p", function() menubar.show() end, { description = "show the menubar", group = "launcher" }),
    })

    awful.keyboard.append_global_keybindings({
        awful.key({ opts.modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
        awful.key({ opts.modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
        awful.key({ opts.modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),
    })

    awful.keyboard.append_global_keybindings({
        awful.key({ opts.modkey }, "j", function() awful.client.focus.byidx(1) end, { description = "focus next by index", group = "client" }),
        awful.key({ opts.modkey }, "k", function() awful.client.focus.byidx(-1) end, { description = "focus previous by index", group = "client" }),
        awful.key({ opts.modkey }, "Tab", function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end, { description = "go back", group = "client" }),
        awful.key({ opts.modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end, { description = "focus the next screen", group = "screen" }),
        awful.key({ opts.modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end, { description = "focus the previous screen", group = "screen" }),
        awful.key({ opts.modkey, "Control" }, "n", function()
            local c = awful.client.restore()
            if c then
                c:activate({ raise = true, context = "key.unminimize" })
            end
        end, { description = "restore minimized", group = "client" }),
    })

    awful.keyboard.append_global_keybindings({
        awful.key({ opts.modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end, { description = "swap with next client by index", group = "client" }),
        awful.key({ opts.modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end, { description = "swap with previous client by index", group = "client" }),
        awful.key({ opts.modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
        awful.key({ opts.modkey }, "l", function() awful.tag.incmwfact(0.05) end, { description = "increase master width factor", group = "layout" }),
        awful.key({ opts.modkey }, "h", function() awful.tag.incmwfact(-0.05) end, { description = "decrease master width factor", group = "layout" }),
        awful.key({ opts.modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end, { description = "increase the number of master clients", group = "layout" }),
        awful.key({ opts.modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end, { description = "decrease the number of master clients", group = "layout" }),
        awful.key({ opts.modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end, { description = "increase the number of columns", group = "layout" }),
        awful.key({ opts.modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end, { description = "decrease the number of columns", group = "layout" }),
        awful.key({ opts.modkey }, "space", function() awful.layout.inc(1) end, { description = "select next", group = "layout" }),
        awful.key({ opts.modkey, "Shift" }, "space", function() awful.layout.inc(-1) end, { description = "select previous", group = "layout" }),
    })

    awful.keyboard.append_global_keybindings({
        awful.key({
            modifiers = { opts.modkey },
            keygroup = "numrow",
            description = "only view tag",
            group = "tag",
            on_press = function(index)
                local screen = awful.screen.focused()
                local t = screen.tags[index]
                if t then
                    t:view_only()
                end
            end,
        }),
        awful.key({
            modifiers = { opts.modkey, "Control" },
            keygroup = "numrow",
            description = "toggle tag",
            group = "tag",
            on_press = function(index)
                local screen = awful.screen.focused()
                local t = screen.tags[index]
                if t then
                    awful.tag.viewtoggle(t)
                end
            end,
        }),
        awful.key({
            modifiers = { opts.modkey, "Shift" },
            keygroup = "numrow",
            description = "move focused client to tag",
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
            modifiers = { opts.modkey, "Control", "Shift" },
            keygroup = "numrow",
            description = "toggle focused client on tag",
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
        awful.key({
            modifiers = { opts.modkey },
            keygroup = "numpad",
            description = "select layout directly",
            group = "layout",
            on_press = function(index)
                local t = awful.screen.focused().selected_tag
                if t then
                    t.layout = t.layouts[index] or t.layout
                end
            end,
        }),
    })
end

return M
