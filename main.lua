require("render")

local bump = require("vendor/bump")
local should_draw_console = require("console")
local gamera = require("vendor/gamera")

CELL_SIZE = 64
BLOCK_SIZE = 32
ENTITY_SIZE = 28
local world = bump.newWorld(CELL_SIZE)

local player = {}
local player_color = { g = 0.5 }
local tiles = {}

local camera = gamera.new(-500, -500, 2500, 2500) -- NOTE:actual camera bounds must be later updated according to generated world size!

function add_box(x, y, w, h)
	local tile = { x = x, y = y, w = w, h = h }
	tiles[#tiles + 1] = tile
	world:add(tile, x, y, w, h)
end

function love.load()
	player.x = 10
	player.y = 200
	player.vx = 0.0
	player.vy = 0.0
	player.w = ENTITY_SIZE
	player.h = ENTITY_SIZE
	player.is_grounded = false
	player.name = "plr"

	world:add(player, player.x, player.y, player.h, player.w)

	-- add a bunch of tiles at the bottom for a ground element
	local tile_count_horizontal = 1280 / BLOCK_SIZE
	for i = 0, tile_count_horizontal do
		y = 720 - BLOCK_SIZE
		add_box(i * BLOCK_SIZE, y, BLOCK_SIZE, BLOCK_SIZE)
	end

	-- add some platforms
	add_box(200, 600, 100, 32)
	add_box(400, 500, 100, 32)
	add_box(600, 400, 100, 32)

	camera:setPosition(player.x, player.y)

	-- turn on debug prints
	should_draw_console = true
end

--
local function update_player(dt)
	local gravity = 9.81 * 10
	local jumpAccel = 2000
	local brakeAccel = 2000
	local runSpeed = 150
	local dragCoeff = 0.9
	-- input handling
	local dx, dy = player.vx, player.vy
	if love.keyboard.isDown("right") then
		dx = dx + runSpeed
	elseif love.keyboard.isDown("left") then
		dx = dx - runSpeed
	end
	-- apply braking if needed
	if not love.keyboard.isDown("left") and dx < 0 then
		dx = dx + brakeAccel * dt
		if dx > 0 then
			dx = 0
		end
	end
	if not love.keyboard.isDown("right") and dx > 0 then
		dx = dx - brakeAccel * dt
		if dx < 0 then
			dx = 0
		end
	end

	if love.keyboard.isDown("space") and player.is_grounded then
		dy = dy - jumpAccel
		player.is_grounded = false
	end

	local jumpFactor = 1.0 -- TODO: this needs a better name
	if love.keyboard.isDown("space") and not player.is_grounded and dy < 0.0 then
		jumpFactor = 0.2 -- TODO: implement frame or time counter for this
	end
	dy = dy + gravity * jumpFactor

	dx = dx * dragCoeff
	dy = dy * dragCoeff

	player.vx, player.vy = dx, dy
	-- physics update
	local cols
	local cols_len = 0
	player.x, player.y, cols, cols_len = world:move(player, player.x + dx * dt, player.y + dy * dt)
	for i = 1, cols_len do
		local col = cols[i]
		--[[console_print(
			("col.other = %s, col.type = %s, col.normal = %d,%d"):format(
				col.other,
				col.type,
				col.normal.x,
				col.normal.y
			)
		)]]
		-- Velocity handling in the collisions -- NOTE: we could set wall grab or
		-- grounded flags here
		-- Vertical collision:
		if col.normal.y ~= 0 then
			player.is_grounded = true
			player.vy = 0
		end
		-- Horizontal collision
		if col.normal.x ~= 0 then
			player.vx = 0
		end
	end
end

function love.update(dt)
	update_player(dt)

	camera:setPosition(player.x, player.y)

	if love.keyboard.isDown("p") then
		should_draw_console = not should_draw_console
	end

	if love.keyboard.isDown("2") then
		local scale_x, _scale_y = camera:getScale()
		if scale_x == 2.0 then
			camera:setScale(1.0)
		else
			camera:setScale(2.0)
		end
	end
end

function love.draw()
	love.graphics.clear()

	camera:draw(function(_l, _t_, _w, _h)
		draw_box(player, player_color)
		draw_tiles(tiles)
	end)
	if should_draw_console then
		draw_console()
	end
end

--[[
--- OPTIONAL CALLBACKS ---
-- You can uncomment these as you need them.

function love.keypressed(key, scancode, isrepeat)
    -- Called when a key is pressed.
end

function love.mousepressed(x, y, button, istouch, presses)
    -- Called when a mouse button is pressed.
end
]]
