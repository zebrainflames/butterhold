-- Require all our files
local gamera = require("vendor/gamera")
local bump = require("vendor/bump")
local LevelGenerator = require("level_generator")
local should_draw_console = require("console")

-- Constants
local TILE_SIZE = 32
local WORLD_CELL_SIZE = 4 * TILE_SIZE
local DEBUG_MODE = false
local ENTITY_SIZE = 28

-- Game world
local world
local level_map, entities, critical_path, level_dims
local player
local camera

function add_box(x, y, w, h)
	local tile = { x = x, y = y, w = w, h = h }
	world:add(tile, x, y, w, h)
end

function generate()
	print("Generating new world...")
	world = bump.newWorld(WORLD_CELL_SIZE)

	LevelGenerator.generate_level("rat's ass", "shit")
end

function love.load()
	print("love.load() called")
	love.window.setMode(1280, 720, { resizable = false })
	camera = gamera.new(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	math.randomseed(os.clock())
	generate()
end

function love.update(dt)
	--player:update(dt, world)
	-- Camera follows player
	--camera:setPosition(player.x, player.y)

	if love.keyboard.isDown("p") then
		should_draw_console = not should_draw_console
	end
end

function love.draw()
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
