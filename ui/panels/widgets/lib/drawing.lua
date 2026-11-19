local M = {}

function M.clamp(value, minimum, maximum)
	return math.max(minimum, math.min(maximum, value))
end

-- Convert #RRGGBB to normalized RGB.
function M.parse_color(color)
	color = color:gsub("#", "")

	return tonumber(color:sub(1, 2), 16) / 255, tonumber(color:sub(3, 4), 16) / 255, tonumber(color:sub(5, 6), 16) / 255
end

function M.set_color(cr, color, alpha)
	local r, g, b = M.parse_color(color)

	cr:set_source_rgba(r, g, b, alpha or 1)
end

-- Interpolate between two hexadecimal colors.
function M.interpolate_color(color_a, color_b, amount)
	local ar, ag, ab = M.parse_color(color_a)
	local br, bg, bb = M.parse_color(color_b)

	amount = M.clamp(amount, 0, 1)

	local r = ar + (br - ar) * amount
	local g = ag + (bg - ag) * amount
	local b = ab + (bb - ab) * amount

	return string.format(
		"#%02x%02x%02x",
		math.floor(r * 255 + 0.5),
		math.floor(g * 255 + 0.5),
		math.floor(b * 255 + 0.5)
	)
end

-- Select/interpolate a color from threshold-based color stops.
function M.color_at_threshold(value, colors)
	local first = colors[1]
	local last = colors[#colors]

	if value <= first.threshold then
		return first.color
	end

	if value >= last.threshold then
		return last.color
	end

	for i = 1, #colors - 1 do
		local a = colors[i]
		local b = colors[i + 1]

		if value >= a.threshold and value <= b.threshold then
			local range = b.threshold - a.threshold

			if range <= 0 then
				return b.color
			end

			local amount = (value - a.threshold) / range

			return M.interpolate_color(a.color, b.color, amount)
		end
	end

	return last.color
end

-- Append a rounded rectangle path to the Cairo context.
-- The caller is responsible for filling or stroking it.
function M.rounded_rectangle(cr, x, y, width, height, radius)
	radius = math.max(0, math.min(radius, width / 2, height / 2))

	if radius <= 0 then
		cr:rectangle(x, y, width, height)
		return
	end

	cr:new_sub_path()

	cr:arc(x + width - radius, y + radius, radius, -math.pi / 2, 0)

	cr:arc(x + width - radius, y + height - radius, radius, 0, math.pi / 2)

	cr:arc(x + radius, y + height - radius, radius, math.pi / 2, math.pi)

	cr:arc(x + radius, y + radius, radius, math.pi, math.pi * 1.5)

	cr:close_path()
end

return M
