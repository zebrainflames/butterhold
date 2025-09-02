local types = require("room_types")

local LevelGenerator = { rooms = {} }

local LEVEL_ROWS = 8
local LEVEL_COLS = 8
local TOTAL_ROOMS = 8 * 8

local TILE_SIZE = 32
local ROOM_ROWS = 10
local ROOM_COLS = 15

local MAX_ROOM_TYPE = 9 -- TODO: get this from templates.lua

-- Generates a sequence of coordinates for the main path of travel in a level
local function LevelGenerator.generate_path()
	local path = {}
	-- TODO: implement me
	return path
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
-- Main orchestrator function
function LevelGenerator.generate_level(biome, all_templates)
	-- 1. set random room type for each room slot
	print("Generating level...")
	for y = 1, LEVEL_ROWS do
		LevelGenerator.rooms[y] = {}
		for x = 1, LEVEL_COLS do
			local r = math.random(0, MAX_ROOM_TYPE)
			print("Adding room type " .. r .. " to coords (" .. x .. "," .. y .. ").")
			LevelGenerator.rooms[y][x] = math.random(0, 9)
		end
	end
	printRooms(LevelGenerator.rooms)
	-- 2. map out critical path; start from top row and iterate through until (out of) bottom row
	local path = LevelGenerator.generate_path()

	-- 3. Assign random room from suitable template categories to each selected room slot according to room type number selected so far
	local tile_data = LevelGenerator.apply_templates(all_templates, path)

	-- 4. randomly spawn loot, hazards and enemies to empty slots on each room (except for entry and exit
	
	-- finally, return generated tile_data for other components to consume
	return tile_data
end

return LevelGenerator
