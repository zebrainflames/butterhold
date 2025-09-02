-- Defines the "theme" for different level types.
local biomes = {
	caves = {
		asset_map = {
			X = { 87 / 255, 50 / 255, 17 / 255 }, -- Brown for walls
			G = { 58 / 255, 33 / 255, 11 / 255 }, -- Darker Brown for ground
			[" "] = { 0, 0, 0, 0 }, -- Transparent for air
		},
		spawn_tables = {
			L = { 1, 1, 0 }, -- Yellow for loot
			E = { 1, 0, 0 }, -- Red for enemies
		},
	},
	goblin_grotto = {
		asset_map = {
			X = { 50 / 255, 87 / 255, 17 / 255 }, -- Green for walls
			G = { 33 / 255, 58 / 255, 11 / 255 }, -- Darker Green for ground
			[" "] = { 0, 0, 0, 0 },
		},
		spawn_tables = {
			L = { 0, 1, 1 }, -- Cyan for loot
			E = { 1, 0, 1 }, -- Magenta for enemies
		},
	},
}
return biomes
