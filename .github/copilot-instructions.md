# Copilot instructions

## Validation

This repository is an AwesomeWM Lua configuration with `rc.lua` as entrypoint plus local modules; it has no package manifest, build script, test suite, or lint configuration.

- Check Lua syntax for all modules: `find . -type f -name '*.lua' -print0 | xargs -0 -n1 luac -p`
- Check AwesomeWM configuration syntax and API-level compatibility: `awesome -k -c rc.lua`
- There is no narrower test target: for config/module changes, run both checks above. Runtime behavior can be checked by reloading AwesomeWM with `Mod4+Control+r`.

The entrypoint declares Awesome's API mode with `-- awesome_mode: api-level=4:screen=on`. `.luarc.json` configures LuaLS for Lua 5.4; shared configuration types live in `.luals/types.lua`.

## Architecture

`rc.lua` is a thin orchestrator that wires modular, event-driven AwesomeWM components:

- `config/user.lua` centralizes theme path and terminal/editor commands; `config/keys/mod.lua` owns modifier names, and `config/windows.lua` owns tunable window geometry/shape values.
- `config/apps.lua` owns default application commands and reload-safe autostart declarations; `core/autostart.lua` launches persistent commands only when no matching user process exists.
- `core/*` provides startup/error support and long-lived data producers. CPU, RAM, and battery modules own their timers/sampling state and emit `awesome` signals; matching `ui/panels/widgets/*` modules consume those signals and render state.
- `ui/*` defines menu, layouts, wallpaper, and switchable screen panels.
- `config/panel.lua` selects the panel preset and workspace widget style; reusable panel widgets live in `ui/panels/widgets/`. `config/themes.lua` owns visual presets, while `core/theme.lua` publishes the active preset onto `beautiful` fields consumed by widgets.
- `config/tags.lua` declares reusable workspace metadata; `ui/tags.lua` creates those icon-only workspaces per screen and manages layout-dependent gaps.
- `bindings/*` splits global and client key/mouse bindings while preserving hotkey metadata and Awesome default extension points.
- `rules/client.lua` and `notifications/init.lua` register ruled client/notification behavior.
- `signals/sloppy_focus.lua` and `signals/client_decoration.lua` isolate focus and conditional border/shape behavior.

## Conventions

- Register behavior through Awesome's request signals (`connect_signal`) and extend defaults with `awful.keyboard.append_*` / `awful.mouse.append_*`; do not replace the framework's default binding tables.
- Keep screen-specific state on the screen object (`s.*`) inside `request::desktop_decoration`; shared widgets/settings belong in modules only when intentionally cross-screen.
- Keep workspace names, icons, launch commands, and default layouts in `config/tags.lua`; consume the module from panels/widgets rather than rebuilding tag metadata.
- Keep modifier names in `config/keys/mod.lua` and popup/dialog geometry or shape tuning in `config/windows.lua`; consume them through modules rather than duplicating literals.
- Keep client border colors, DPI-scaled sizes, corner radius, and popup/dialog geometry in `config/windows.lua`; update decoration state through client/layout signals.
- Add persistent startup programs to `config.apps.run_on_start_up` with both `command` and `process`; put idempotent setup commands in `run_on_start_up_commands`.
- Use `ruled.client.append_rule` and `ruled.notification.append_rule` for matching and properties rather than ad hoc client/notification handlers.
- Keep `rc.lua` minimal and orchestration-only; place feature logic into focused modules (`ui/`, `bindings/`, `rules/`, `signals/`, `core/`) to avoid a monolithic config.
- Keep keybinding metadata (`description` and `group`) with each binding because it drives the `awful.hotkeys_popup` help.
- Reuse the configured `terminal`, `editor_cmd`, `modkey`, and theme values instead of duplicating literals. Changes to launch behavior should update the central variable definitions.
- Follow the existing declarative widget style: nested tables describe widget layout, while callbacks handle only interaction and state changes.
- Scale new geometry and font sizes with `beautiful.xresources.apply_dpi`; keep appearance/timing controls in the relevant `config/*.lua` module rather than in widget rendering code.
- Keep long-lived collectors idempotent: CPU, RAM, and battery modules guard module-level sampling state so recreated panels do not create duplicate timers. CPU and RAM also provide explicit `stop()` lifecycle support.
- Keep LuaLS annotations synchronized when changing public configuration shapes. Add or update the matching `---@class` in `.luals/types.lua`, not only local fields in a config table.
- Use the supported session-level overrides `AWESOME_THEME`, `AWESOME_PANEL_STYLE`, and `AWESOME_WORKSPACE_STYLE` for temporary visual changes; invalid panel/theme selections are errors, while an invalid workspace style falls back to `indicator`.
