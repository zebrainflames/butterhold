-- vendored deps
local gamera = require("vendor/gamera")
local bump = require("vendor/bump")

-- game systems
local LevelGenerator = require("level_generator")
require("templates")

local room_templates = AllTemplates()

-- game objects
local Player = require("player")

--utils
local should_draw_console = require("console")

-- Constants
local TILE_SIZE = 32
local WORLD_CELL_SIZE = 4 * TILE_SIZE
local DEBUG_MODE = false
local ENTITY_SIZE = 28
local CAMERA_BUFFER_PIXELS = 256

-- Game world & systems
local world
local player
local camera
local camera_follow = true

local function add_box(x, y, w, h)
	local tile = { x = x, y = y, w = w, h = h }
	world:add(tile, x, y, w, h)
end

local function generate()
	print("Generating new world...")
	world = bump.newWorld(WORLD_CELL_SIZE)

	LevelGenerator.generate_level(world, "caves", room_templates)
	player = Player.new(LevelGenerator.entry.x, LevelGenerator.entry.y, ENTITY_SIZE, ENTITY_SIZE)
	world:add(player, player.x, player.y, player.w, player.h)
end

function love.load()
	print("love.load() called")
	love.window.setMode(1280, 720, { resizable = false })
	camera = gamera.new(
		-CAMERA_BUFFER_PIXELS,
		-CAMERA_BUFFER_PIXELS,
		LevelGenerator.world_width() + CAMERA_BUFFER_PIXELS * 2,
		LevelGenerator.world_height() + CAMERA_BUFFER_PIXELS * 2
	)
	camera:setPosition(1000, 200)
	math.randomseed(os.clock())
	generate()
end

function love.update(dt)
	player:update(dt, world)

	if camera_follow and player then
		camera:setPosition(player.x, player.y)
	else
		local dx, dy = 0.0, 0.0
		if love.keyboard.isDown("left") then
			dx = dx - 1.0
		end
		if love.keyboard.isDown("right") then
			dx = dx + 1.0
		end
		if love.keyboard.isDown("up") then
			dy = dy - 1.0
		end
		if love.keyboard.isDown("down") then
			dy = dy + 1.0
		end

		local cx, cy = camera:getPosition()
		local camera_move_speed = 10.0
		camera:setPosition(cx + dx * camera_move_speed, cy + dy * camera_move_speed)
	end

	if love.keyboard.isDown("p") then
		should_draw_console = not should_draw_console
	end
end

-- non_player restricts bump to query only for level geometry / tiles
local function non_player(object)
	if object.name and object.name == "plr" then
		return false
	end
	return true
end

local function render_world_tiles(l, t, w, h)
	local tiles, len = world:queryRect(l, t, w, h, non_player)
	--print("Found #" .. len .. " renderable objects...")
	for i = 1, len do
		local tile = tiles[i]
		local sym = tile.sym
		local col = { 0, 0, 0 }
		if sym == "R" then
			col = { 50 / 255, 50 / 255, 50 / 255 }
		elseif sym == "G" then
			col = { 68 / 255, 70 / 255, 30 / 255 }
		elseif sym == "X" then
			col = { 20 / 255, 60 / 255, 120 / 255 }
		elseif sym == " " then
			col = { 220 / 255, 220 / 255, 220 / 255, 220 / 255 } -- XD white air
		elseif sym == "W" then
			col = { 120 / 255, 120 / 255, 120 / 255 }
		elseif sym == "D" then -- door
			col = { 0.1, 0.1, 0.95 }
		else
			print("WARNING: UNKNOWN SYMBOL " .. sym .. " IN ROOM TABLE")
		end
		love.graphics.setColor(col)
		love.graphics.rectangle("fill", tile.x, tile.y, TILE_SIZE, TILE_SIZE)
	end
	love.graphics.setColor(1, 1, 1, 1)
end

function render_frame(l, t, w, h)
	render_world_tiles(l, t, w, h)

	love.graphics.rectangle("line", player.x, player.y, player.w, player.h)

	--local col = { 0.2, 0.8, 0.4 }
	--LevelGenerator.render_room_rect(1, 4, col)
	LevelGenerator.debug_render_current_map()
end

function love.draw()
	camera:draw(render_frame)

	-- UI/Overlay drawing (not affected by camera)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Press F1 for Debug View | Press R to Regenerate", 10, 10)
	if DEBUG_MODE then
		love.graphics.print("DEBUG MODE ACTIVE", 10, 30)
		love.graphics.print("Player state: " .. player.debug_state, 10, 60)
	end
	if should_draw_console then
		draw_console()
	end
end

local function toggle_camera_mode()
	print("Toggling camera")
	if camera_follow then
		--> switch to zoomed out
		camera:setScale(0.2)
		local center = LevelGenerator.world_center()
		camera:setPosition(center.x, center.y)
	else
		--> switch to camera follow
		camera:setScale(1.0)
	end
	camera_follow = not camera_follow
end

function love.keypressed(key)
	if key == "f1" then
		DEBUG_MODE = not DEBUG_MODE
	elseif key == "r" then
		generate()
	elseif key == "1" then
		toggle_camera_mode()
	elseif key == "p" then
		local r = math.random()
		print("Got random number: " .. r)
	end
end

function love.resize(w, h)
	camera:setWindow(0, 0, w, h)
end
