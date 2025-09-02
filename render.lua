local function safe_color(color)
	color = color or { r = 1, g = 1, b = 1 }
	color.r = color.r or 0.0
	color.g = color.g or 0.0
	color.b = color.b or 0.0
	return color
end

function draw_box(box, color)
	local sc = safe_color(color)
	love.graphics.setColor(sc.r, sc.g, sc.b, 0.25)
	love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
	love.graphics.setColor(sc.r, sc.g, sc.b)
	love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
end

function draw_tiles(tiles, color)
	for _, tile in ipairs(tiles) do
		draw_box(tile, color)
	end
end
