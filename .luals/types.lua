---@meta

---@class ModKeys
---@field modKey string
---@field altKey string

---@class AppDefaults
---@field terminal string
---@field rofi string
---@field lock string
---@field quake string
---@field screenshot string
---@field region_screenshot string
---@field delayed_screenshot string
---@field browser string
---@field browser2 string
---@field editor string
---@field editor2 string
---@field social string
---@field game string
---@field files string
---@field tfiles string
---@field music string

---@class AutostartEntry
---@field command string
---@field process string Exact process name used by pgrep.

---@class AppsConfig
---@field default AppDefaults
---@field run_on_start_up AutostartEntry[]
---@field run_on_start_up_commands string[]

---@class UserSettings
---@field terminal string
---@field editor string
---@field editor_cmd string
---@field apps AppsConfig
---@field modkey string
---@field altkey string
---@field theme string

---@class WindowSettings
---@field client_border_width number
---@field client_border_color string
---@field client_border_color_inactive string
---@field client_corner_radius number
---@field dialog_max_width_ratio number
---@field dialog_max_height_ratio number

---@class WorkspaceDefinition
---@field name string
---@field type string
---@field icon string
---@field default_app string
---@field layout unknown

---@class PanelPreset
---@field position "top"|"bottom"
---@field height number
---@field margin number
---@field spacing number
---@field workspace_style "indicator"|"pill"
---@field clock_format string

---@class PanelConfig
---@field style "top"|"bottom"
---@field presets table<"top"|"bottom", PanelPreset>

---@class GlobalBindingOptions
---@field modkey string
---@field altkey string
---@field apps AppsConfig
---@field menu unknown

---@class ClientBindingOptions
---@field modkey string
---@field altkey string

---@class PanelOptions
---@field modkey string
---@field launcher unknown
