-- Require all our files
local gamera = require("vendor/gamera")
local bump = require("vendor/bump")
local Player = require("player")
local LevelGenerator = require("level_generator")
local ALL_TEMPLATES = require("templates")
local ALL_BIOMES = require("biomes")
local should_draw_console = require("console")

-- Constants
local TILE_SIZE = 32
local DEBUG_MODE = false
local ENTITY_SIZE = 28

-- Game world
local world = bump.newWorld(TILE_SIZE)
local level_map, entities, critical_path, level_dims
local player
local camera

function add_box(x, y, w, h)
	local tile = { x = x, y = y, w = w, h = h }
	world:add(tile, x, y, w, h)
end

function generate()
	world = bump.newWorld(TILE_SIZE)
	local biomes_list = { "caves", "goblin_grotto" }
	local biome_name = biomes_list[math.random(#biomes_list)]
	local biome = ALL_BIOMES[biome_name]
	level_map, entities, critical_path, level_dims = LevelGenerator.generate_level(biome, ALL_TEMPLATES)
	camera:setWorld(0, 0, level_dims.width * TILE_SIZE, level_dims.height * TILE_SIZE)

	-- Add level geometry to the physics world
	for y = 1, level_dims.height do
		if level_map[y] then
			for x = 1, level_dims.width do
				local tile = level_map[y][x]
				if tile and tile[4] ~= 0 then
					add_box((x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
				end
			end
		end
	end

	-- Place player at the start of the critical path
	local start_pos = critical_path[1]
	local room_width = #ALL_TEMPLATES["L-R"][1].tiles[1]
	local room_height = #ALL_TEMPLATES["L-R"][1].tiles

	local spawn_x, spawn_y
	local start_room_x = (start_pos.x - 1) * room_width
	local start_room_y = (start_pos.y - 1) * room_height

	for y = 1, room_height do
		if level_map[start_room_y + y] then
			for x = 1, room_width do
				if not level_map[start_room_y + y][start_room_x + x] then
					spawn_x = (start_room_x + x - 1) * TILE_SIZE
					spawn_y = (start_room_y + y - 1) * TILE_SIZE
					goto found_spawn
				end
			end
		end
	end
	::found_spawn::

	if not spawn_x then
		-- Fallback to center of the room if no empty space is found
		spawn_x = (start_pos.x - 0.5) * room_width * TILE_SIZE
		spawn_y = (start_pos.y - 0.5) * room_height * TILE_SIZE
	end

	player = Player.new(spawn_x, spawn_y, ENTITY_SIZE, ENTITY_SIZE)
	world:add(player, player.x, player.y, player.w, player.h)
end

function love.load()
	print("love.load() called")
	love.window.setMode(1280, 720, { resizable = true })
	camera = gamera.new(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	generate()
end

function love.update(dt)
	player:update(dt, world)
	-- Camera follows player
	camera:setPosition(player.x, player.y)

	if love.keyboard.isDown("p") then
		should_draw_console = not should_draw_console
	end
end

function love.draw()
	camera:draw(function(l, t, w, h)
		-- Get camera bounds for visibility culling
		local start_col = math.max(1, math.floor(l / TILE_SIZE))
		local end_col = math.min(level_dims.width, math.ceil((l + w) / TILE_SIZE))
		local start_row = math.max(1, math.floor(t / TILE_SIZE))
		local end_row = math.min(level_dims.height, math.ceil((t + h) / TILE_SIZE))

		-- Draw only the visible tiles
		for y = start_row, end_row do
			if level_map[y] then
				for x = start_col, end_col do
					if level_map[y][x] then
						love.graphics.setColor(level_map[y][x])
						love.graphics.rectangle("fill", (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
					end
				end
			end
		end

		-- Draw critical path
		local room_width_tiles = #ALL_TEMPLATES["L-R"][1].tiles[1]
		local room_height_tiles = #ALL_TEMPLATES["L-R"][1].tiles
		love.graphics.setColor(0, 0, 1, 0.5) -- Blue, semi-transparent
		love.graphics.setLineWidth(4)
		for i = 1, #critical_path - 1 do
			local p1 = critical_path[i]
			local p2 = critical_path[i + 1]
			local x1 = (p1.x - 0.5) * room_width_tiles * TILE_SIZE
			local y1 = (p1.y - 0.5) * room_height_tiles * TILE_SIZE
			local x2 = (p2.x - 0.5) * room_width_tiles * TILE_SIZE
			local y2 = (p2.y - 0.5) * room_height_tiles * TILE_SIZE
			love.graphics.line(x1, y1, x2, y2)
		end

		-- Draw entrance and exit
		local start_pos = critical_path[1]
		local end_pos = critical_path[#critical_path]

		local start_x = (start_pos.x - 0.5) * room_width_tiles * TILE_SIZE
		local start_y = (start_pos.y - 0.5) * room_height_tiles * TILE_SIZE
		love.graphics.setColor(0, 0, 1) -- Blue
		love.graphics.rectangle("fill", start_x - TILE_SIZE / 2, start_y - TILE_SIZE / 2, TILE_SIZE, TILE_SIZE)

		local end_x = (end_pos.x - 0.5) * room_width_tiles * TILE_SIZE
		local end_y = (end_pos.y - 0.5) * room_height_tiles * TILE_SIZE
		love.graphics.setColor(0, 1, 0) -- Green
		love.graphics.rectangle("fill", end_x - TILE_SIZE / 2, end_y - TILE_SIZE / 2, TILE_SIZE, TILE_SIZE)

		-- Draw entities
		for _, entity in ipairs(entities) do
			love.graphics.setColor(entity.color)
			love.graphics.rectangle("fill", entity.x, entity.y, TILE_SIZE, TILE_SIZE)
		end

		-- Debug drawing
		if DEBUG_MODE then
			draw_debug()
		end

		-- Draw player
		love.graphics.setColor(1, 1, 1)
		love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)
	end)

	-- UI/Overlay drawing (not affected by camera)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Press F1 for Debug View | Press R to Regenerate", 10, 10)
	if DEBUG_MODE then
		love.graphics.print("DEBUG MODE ACTIVE", 10, 30)
	end
	if should_draw_console then
		draw_console()
	end
end

function draw_debug()
	-- Draw room boundaries
	local room_width_tiles = #ALL_TEMPLATES["L-R"][1].tiles[1]
	local room_height_tiles = #ALL_TEMPLATES["L-R"][1].tiles
	love.graphics.setColor(0, 1, 0)
	love.graphics.setLineWidth(1)
	for y = 0, 7 do
		for x = 0, 7 do
			love.graphics.rectangle(
				"line",
				x * room_width_tiles * TILE_SIZE,
				y * room_height_tiles * TILE_SIZE,
				room_width_tiles * TILE_SIZE,
				room_height_tiles * TILE_SIZE
			)
		end
	end
end

function love.keypressed(key)
	if key == "f1" then
		DEBUG_MODE = not DEBUG_MODE
	elseif key == "r" then
		generate()
	end
end

function love.resize(w, h)
	camera:setWindow(0, 0, w, h)
end

