--- TILE RULES
--- G == ground the player collides with but can mine with the pick axe. Low chance of spawning with gems / gold
--- R == rock - harder to mine ground tiles. Undecided if this will be breakable with just pickaxe?
--- X == rock or ground, 50/50 chance
--- W == wall - biome specific walls, breakable (easier than Rock)
--- " " == empty space, low chance of enemies or loot
--- L == ladder - high chance of loot spawning here
--- W == wooden structures, or other similar things per biome
--- E == entity or enemy

-- The room's shape is the KEY. The value is a list of variations.
local templates = {
	-- horizontal corridor, some variations have optional drops or openings
	horizontal = {
		-- Variation 1
		{
			{ "X", "X", "X", "X", "X", "X", "X", "G", "G", "X", "R", "X", "X", "X", "X", "X" },
			{ "X", "X", "X", " ", "X", "R", "G", " ", "X", "X", "G", " ", " ", " ", " ", "X" },
			{ "X", "X", "X", " ", " ", "R", "G", " ", " ", "X", " ", " ", " ", " ", " ", "X" },
			{ " ", "X", "X", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", " " },
			{ " ", " ", "X", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", " " },
			{ " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " " },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", " ", " ", " ", "G", "G", " ", " ", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", " ", " ", "G", "R", "R", " ", "X", " ", " ", " ", " ", " ", "X" },
			{ "X", "X", "X", "X", "X", "X", "R", "R", "X", "X", "X", "X", "X", "X", "X", "X" },
		},
	},
	-- vertical corridor / pit
	vertical = {
		{
			{ "X", "X", "X", "X", "X", "X", " ", " ", " ", " ", " ", "X", "X", "X", "X", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", "R", "R", "R", " ", " ", " ", " ", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", "G", "G", "G", " ", " ", " ", " ", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", " ", "G", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", "G", "G", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", "X" },
			{ "X", "X", "X", "X", " ", " ", " ", " ", "X", "X", "X", "X", "X", "X", "X", "X" },
		},
	},
	-- Key for a corner with exits Up and Right
	up_right = {
		{
			{ "X", "X", "X", "X", "X", "X", " ", " ", " ", " ", " ", "X", "X", "X", "X", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", "G" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", " " },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", " " },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " " },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", "G", "G" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", "G", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", "G", "G", "X" },
			{ "X", "X", "X", "X", "G", "G", "G", "G", "X", "X", "X", "X", "X", "X", "X", "X" },
		},
	},
	-- Key for a T-junction with no top exit
	t_junction = {
		{
			{ "X", "X", "X", "X", "X", "X", "X", "X", "X", "X", "X", "X", "X", "X", "X", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", "X" },
			{ " ", " ", " ", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", " " },
			{ " ", " ", " ", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", " " },
			{ " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " " },
			{ " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " " },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", "X" },
			{ "X", "X", "X", "X", " ", " ", " ", " ", "X", "X", "X", "X", "X", "X", "X", "X" },
		},
	},
	-- Key for a 4-way intersection
	four_way = {
		{
			{ "X", "X", "X", "X", "X", "X", " ", " ", " ", " ", " ", "X", "X", "X", "X", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", "X" },
			{ " ", " ", " ", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", " " },
			{ " ", " ", " ", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", " " },
			{ " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " " },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", "X", " ", " ", " ", " ", " ", "X" },
			{ "X", "X", "X", "X", " ", " ", " ", " ", "X", "X", "X", "X", "X", "X", "X", "X" },
		},
	},
	-- A key for empty rooms with no required exits
	empty = {
		{
			{ "X", "X", "X", "X", "X", "X", " ", " ", " ", " ", " ", "X", "X", "X", "X", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", " ", " ", " ", "G", "G", "G", "G", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", "X" },
			{ "X", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", "X" },
			{ "X", "X", "X", "X", "G", "G", "G", "G", "X", "X", "X", "X", "X", "X", "X", "X" },
		},
	},
}
local function validate_room_tiles(room, name, index)
	local ROOM_ROWS = 10 -- TODO refactor into level generator or use this module from level generator
	local ROOM_COLS = 16
	if #room ~= ROOM_ROWS then
		local msg = "ERROR: invalid row count! ('" .. name .. "', idx:" .. index .. ")."
		return false, msg
	end
	for i = 1, #room do
		if #room[i] ~= ROOM_COLS then
			local msg = "ERROR: invalid column count "
				.. #room[i]
				.. " in row: "
				.. i
				.. "('"
				.. name
				.. "', idx:"
				.. index
				.. ")."

			return false, msg
		end
	end
	print("Room is valid")
	return true, ""
end

local validated = false
local function validate_templates()
	if validated then
		return
	end
	for id, variations in pairs(templates) do
		for i, variant in ipairs(variations) do
			local valid, err = validate_room_tiles(variant, id, i) -- TODO: return result and report errors with id and i here.
			if not valid then
				error(err)
			end
		end
	end
	validated = true
	return validated
end

function AllTemplates()
	if not validate_templates() then
		error("ERROR: Invalid room template!")
	end
	return templates
end
