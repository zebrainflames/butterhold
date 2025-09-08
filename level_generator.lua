local LevelGenerator = { rooms = {}, path = {}, entry = {} }

local LEVEL_ROWS = 7
local LEVEL_COLS = 5

local TILE_SIZE = 32
local ROOM_ROWS = 10
local ROOM_COLS = 16

local ROOM_WIDTH_PIXELS = ROOM_COLS * TILE_SIZE
local ROOM_HEIGHT_PIXELS = ROOM_ROWS * TILE_SIZE

local WORLD_WIDTH_PIXELS = LEVEL_COLS * ROOM_COLS * TILE_SIZE
local WORLD_HEIGHT_PIXELS = LEVEL_ROWS * ROOM_ROWS * TILE_SIZE

local MAX_ROOM_TYPE = 9 -- TODO: get this from templates.lua

function LevelGenerator.world_width()
	return WORLD_WIDTH_PIXELS
end

function LevelGenerator.world_height()
	return WORLD_HEIGHT_PIXELS
end

function LevelGenerator.world_center()
	return { x = WORLD_WIDTH_PIXELS / 2.0, y = WORLD_HEIGHT_PIXELS / 2.0 }
end

function LevelGenerator.entry_coords_from(coord_x, coord_y) end

function LevelGenerator.room_pixel_coords(coord_x, coord_y)
	--love.graphics.rectangle("fill", x, y, w, h)
	local cx = (coord_x - 1) * ROOM_WIDTH_PIXELS -- lua 1-indexing related offsets..!
	local cy = (coord_y - 1) * ROOM_HEIGHT_PIXELS
	return { x = cx, y = cy }
end

function LevelGenerator.render_room_rect(coord_x, coord_y, color)
	color = color or { 1, 1, 1, 1 }
	local px = LevelGenerator.room_pixel_coords(coord_x, coord_y)
	love.graphics.setColor(color)
	love.graphics.rectangle("fill", px.x, px.y, ROOM_WIDTH_PIXELS, ROOM_HEIGHT_PIXELS)
	love.graphics.setColor(1, 1, 1, 1)
end

function LevelGenerator.apply_templates(all_templates)
	-- TODO: implement me
end

local function printRooms(rooms)
	print("ROOMS:\n")
	for y = 1, LEVEL_ROWS do
		for x = 1, LEVEL_COLS do
			io.write(rooms[y][x])
		end
		print("")
	end
end

local function add_tile(world, sym, x, y, w, h)
	local tile = { sym = sym, x = x, y = y, w = w, h = h }
	world:add(tile, x, y, w, h)
	print("added tile tow world at (" .. x .. "," .. y .. ").")
end

-- apply_room parses the given level template and generates tiles accordingly
-- NOTE:will be expanded to apply biome specific sub-templating
local function apply_room(world, biome, sx, sy, template, create_door)
	create_door = create_door or false
	local empty_slots = {}
	for y = 1, #template do
		for x = 1, #template[1] do
			local sym = template[y][x]
			if sym ~= " " then
				local tx = (sx - 1) * ROOM_COLS * TILE_SIZE + (x - 1) * TILE_SIZE
				local ty = (sy - 1) * ROOM_ROWS * TILE_SIZE + (y - 1) * TILE_SIZE
				if sym == "D" then
					create_door = false -- don't create door if its position is already provided in the template
					LevelGenerator.entry.x = tx
					LevelGenerator.entry.y = ty
				end

				add_tile(world, template[y][x], tx, ty, TILE_SIZE, TILE_SIZE)
			elseif create_door then
				table.insert(empty_slots, { x = x, y = y })
			end
		end
	end

	if create_door then
		local n = math.random(1, #empty_slots)
		print("Creating door in position #" .. n)
		local x, y = empty_slots[n].x, empty_slots[n].y
		add_tile(
			world,
			"D",
			(sx - 1) * ROOM_COLS * TILE_SIZE + (x - 1) * TILE_SIZE, -- lua 1-indexing related offsets..!
			(sy - 1) * ROOM_ROWS * TILE_SIZE + (y - 1) * TILE_SIZE,
			TILE_SIZE,
			TILE_SIZE
		)
		local tx = (sx - 1) * ROOM_COLS * TILE_SIZE + (x - 1) * TILE_SIZE
		local ty = (sy - 1) * ROOM_ROWS * TILE_SIZE + (y - 1) * TILE_SIZE
		LevelGenerator.entry.x = tx
		LevelGenerator.entry.y = ty
	end
end

-- Main orchestrator function
function LevelGenerator.generate_level(world, biome, all_templates, seed)
	if not seed then
		seed = os.time()
	end
	math.randomseed(seed)
	LevelGenerator.path = {}
	-- initialize all rooms to random starting state...
	print("Generating level...")
	for y = 1, LEVEL_ROWS do
		LevelGenerator.rooms[y] = {}
		for x = 1, LEVEL_COLS do
			local r = math.random(0, MAX_ROOM_TYPE)
			--print("Adding room type " .. r .. " to coords (" .. x .. "," .. y .. ").")
			LevelGenerator.rooms[y][x] = math.random(0, 9)
		end
	end
	printRooms(LevelGenerator.rooms)
	-- select room on top row to start from:
	local start_y = 1
	local start_x = math.random(1, LEVEL_COLS)
	print("Start room: (" .. start_x .. ", " .. start_y .. ").")
	apply_room(world, biome, start_x, start_y, all_templates.empty[1], true)
	table.insert(LevelGenerator.path, { x = start_x, y = start_y })
	-- start random walk
	-- TODO: implement random walk
	local dir = 0
	local current_x, current_y = start_x, start_y
	local walking = true
	print("Starting random walk")
	while walking do
		-- 5% chance to directly drop down
		if math.random() <= 0.20 then
			-- TODO: create a function so we can cleanly reuse it in horizontal movement code
			local next_x, next_y = current_x, current_y + 1
			-- when dropping down, we need to check if we are actually dropping out of bounds in ROOM_ROWS -> that's level exit
			if next_y > LEVEL_ROWS then
				walking = false
				print("Found exit at (" .. current_x .. "," .. current_y .. ").")
			else
				table.insert(LevelGenerator.path, { x = next_x, y = next_y })
				-- reset direction for horizontal movement for more natural behaviour
				dir = 0
				print("Dropped down from (" .. current_x .. "," .. current_y .. ").")
				current_x, current_y = next_x, next_y
			end
		else
			-- no dir flag set -> choose one
			if dir == 0 then
				if current_x >= LEVEL_COLS then
					dir = -1
				elseif current_x <= 1 then
					dir = 1
				elseif math.random() < 0.5 then
					dir = 1
					print("Dir: right")
				else
					dir = -1
					print("Dir: left")
				end
			end

			local next_x, next_y = current_x + dir, current_y
			-- if we would move out of bounds horizontally, drop down instead
			if next_x < 1 or next_x > LEVEL_COLS then
				-- TODO: use function defined above (`drop_down`)
				next_x, next_y = current_x, current_y + 1
				if next_y > LEVEL_ROWS then
					walking = false
					print("Found exit at (" .. current_x .. "," .. current_y .. "). (Horizontal movement last)")
				else
					table.insert(LevelGenerator.path, { x = next_x, y = next_y })
					dir = 0
				end

				print("Dropped down from (" .. current_x .. "," .. current_y .. "). (from horizontal movement)")
			else
				-- normal horizontal movement
				print("Moving horizontally")
				table.insert(LevelGenerator.path, { x = next_x, y = next_y })
			end

			current_x, current_y = next_x, next_y
		end
	end
	print("Random walk ended.")
end

function LevelGenerator.randomize_current_map()
	return LevelGenerator.rooms
end

function LevelGenerator.debug_render_current_map()
	local color = { 1, 0, 1 }
	if not LevelGenerator.rooms or not LevelGenerator.rooms[1] then
		return
	end

	-- render grid representation of rooms
	for y = 1, LEVEL_ROWS do
		for x = 1, LEVEL_COLS do
			love.graphics.setColor(color)

			local screen_x = (x - 1) * ROOM_WIDTH_PIXELS
			local screen_y = (y - 1) * ROOM_HEIGHT_PIXELS

			love.graphics.rectangle("line", screen_x, screen_y, ROOM_WIDTH_PIXELS, ROOM_HEIGHT_PIXELS)
		end
	end

	-- render each room on critical path in slightly changing (darkening) color
	local path_color = { 0.2, 0.2, 0.92, 0.8 }
	local start_color = { 0.3, 0.3, 0.3, 0.8 }
	local end_color = { 0.3, 0.92, 0.3, 0.8 }
	for i, coords in pairs(LevelGenerator.path) do
		local room_color = path_color
		if i == 1 then
			room_color = start_color
		end
		if i == #LevelGenerator.path then
			room_color = end_color
		end
		LevelGenerator.render_room_rect(coords.x, coords.y, room_color)
		path_color[3] = path_color[3] - 0.02
		path_color[2] = path_color[2] + 0.02
	end

	love.graphics.setColor(1, 1, 1, 1)
end

return LevelGenerator
