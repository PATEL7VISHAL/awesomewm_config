local dpi = require("beautiful.xresources").apply_dpi

---@type WindowSettings
return {
    client_border_width = dpi(1),
    client_border_color = "#6DC3EC",
    client_border_color_inactive = "#111820",
    client_corner_radius = dpi(10),
    dialog_max_width_ratio = 0.9,
    dialog_max_height_ratio = 0.9,
    popup_corner_radius = dpi(8),
    tooltip_margin_leftright = dpi(12),
    tooltip_margin_topbottom = dpi(8),
    tooltip_tail_size = dpi(6),
    tooltip_gap = dpi(3),
}
