Of course. Here is the complete code for the LÖVE2D dungeon generator compiled into a single markdown document for your reference.

# LÖVE2D Dungeon Generator Code

This document contains the complete source code for the procedural dungeon generator. The project is structured into several Lua files. To run this code, you'll need the LÖVE2D framework and the `gamera.lua` library placed in a `vendor/` subfolder.

-----

## `conf.lua`

```lua
function love.conf(t)
    t.window.title = "Dwarf Hold Generator"
    t.window.width = 1280
    t.window.height = 720
    t.window.vsync = true
end
```

-----

## `main.lua`

```lua
-- Require all our files
local gamera = require("vendor/gamera")
local Player = require("player")
local LevelGenerator = require("level_generator")
local ALL_TEMPLATES = require("templates")
local ALL_BIOMES = require("biomes")

-- Constants
local TILE_SIZE = 32
local DEBUG_MODE = false

local level_map, entities, critical_path, level_dims
local player
local camera

function generate()
    local biome_name = {"caves", "goblin_grotto"}[math.random(2)]
    local biome = ALL_BIOMES[biome_name]
    level_map, entities, critical_path, level_dims = LevelGenerator.generate_level(biome, ALL_TEMPLATES)

    -- Place player at the start of the critical path
    local start_pos = critical_path[1]
    local room_width = #ALL_TEMPLATES["L-R"][1].tiles[1]
    local room_height = #ALL_TEMPLATES["L-R"][1].tiles
    local player_x = (start_pos.x - 0.5) * room_width * TILE_SIZE
    local player_y = (start_pos.y - 0.5) * room_height * TILE_SIZE

    if player then
        player.x, player.y = player_x, player_y
    else
        player = Player.new(player_x, player_y)
    end
end

function love.load()
    love.window.setMode(1280, 720, {resizable=true})
    camera = gamera.new(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    generate()
end

function love.update(dt)
    player:update(dt)
    -- Camera follows player and is clamped to the level boundaries
    camera:setPosition(player.x, player.y)
    camera:clamp(0, 0, level_dims.width * TILE_SIZE, level_dims.height * TILE_SIZE)
end

function love.draw()
    camera:attach()

    -- Get camera bounds for visibility culling
    local l, t, w, h = camera:getView()
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
    love.graphics.rectangle("fill", player.x - TILE_SIZE/2, player.y - TILE_SIZE/2, TILE_SIZE, TILE_SIZE)

    camera:detach()

    -- UI/Overlay drawing (not affected by camera)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Press F1 for Debug View | Press R to Regenerate", 10, 10)
    if DEBUG_MODE then
        love.graphics.print("DEBUG MODE ACTIVE", 10, 30)
    end
end

function draw_debug()
    -- Draw critical path line
    local room_width_tiles = #ALL_TEMPLATES["L-R"][1].tiles[1]
    local room_height_tiles = #ALL_TEMPLATES["L-R"][1].tiles
    love.graphics.setColor(1,0,1)
    love.graphics.setLineWidth(4)
    for i = 1, #critical_path - 1 do
        local p1 = critical_path[i]
        local p2 = critical_path[i+1]
        local x1 = (p1.x - 0.5) * room_width_tiles * TILE_SIZE
        local y1 = (p1.y - 0.5) * room_height_tiles * TILE_SIZE
        local x2 = (p2.x - 0.5) * room_width_tiles * TILE_SIZE
        local y2 = (p2.y - 0.5) * room_height_tiles * TILE_SIZE
        love.graphics.line(x1, y1, x2, y2)
    end

    -- Draw room boundaries
    love.graphics.setColor(0, 1, 0)
    love.graphics.setLineWidth(1)
    for y = 0, 7 do
        for x = 0, 7 do
            love.graphics.rectangle("line", x * room_width_tiles * TILE_SIZE, y * room_height_tiles * TILE_SIZE, room_width_tiles * TILE_SIZE, room_height_tiles * TILE_SIZE)
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
```

-----

## `player.lua`

```lua
Player = {}
Player.__index = Player

function Player.new(x, y)
    local self = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.speed = 300
    return self
end

function Player:update(dt)
    if love.keyboard.isDown("w") then
        self.y = self.y - self.speed * dt
    end
    if love.keyboard.isDown("s") then
        self.y = self.y + self.speed * dt
    end
    if love.keyboard.isDown("a") then
        self.x = self.x - self.speed * dt
    end
    if love.keyboard.isDown("d") then
        self.x = self.x + self.speed * dt
    end
end
```

-----

## `templates.lua`

```lua
-- The room's shape is the KEY. The value is a list of variations.
local templates = {
    -- Key for a horizontal corridor
    ["L-R"] = {
        -- Variation 1
        {
            tiles = {
                {"X","X","X","X","X"},
                {" ","G","E","G"," "},
                {"X","X","X","X","X"},
            }
        },
        -- Variation 2 (different layout, same shape)
        {
            tiles = {
                {"X","X","L","X","X"},
                {" "," "," "," "," "},
                {"X","X","X","X","X"},
            }
        }
    },
    -- Key for a vertical corridor
    ["U-D"] = {
        {
            tiles = {
                {"X"," ","X"},
                {"X","G","X"},
                {"X"," ","X"},
                {"X","G","X"},
                {"X"," ","X"},
            }
        }
    },
    -- Key for a corner with exits Up and Right
    ["U-R"] = {
        {
            tiles = {
                {"X"," ","X","X","X"},
                {" ","G"," "," ","X"},
                {"X"," ","E"," "," "},
                {"X","X","X","L","X"},
            }
        }
    },
    -- Key for a T-junction with no top exit
    ["D-L-R"] = {
        {
            tiles = {
                {"X","X","X","X","X"},
                {" "," ","G"," "," "},
                {" ","G"," ","G"," "},
                {"X"," ","L"," ","X"},
                {"X","X"," ","X","X"},
            }
        }
    },
    -- Key for a 4-way intersection
    ["U-D-L-R"] = {
        {
            tiles = {
                {"X","X"," ","X","X"},
                {" ","G"," ","G"," "},
                {" "," ","E"," "," "},
                {" ","G"," ","G"," "},
                {"X","X"," ","X","X"},
            }
        }
    },
    -- A key for empty rooms with no required exits
    ["EMPTY"] = {
        {
            tiles = {
                {"X","X","X","X","X"},
                {"X","G","G","G","X"},
                {"X","G","L","G","X"},
                {"X","G","G","G","X"},
                {"X","X","X","X","X"},
            }
        }
    }
}
return templates
```

-----

## `biomes.lua`

```lua
-- Defines the "theme" for different level types.
local biomes = {
    caves = {
        asset_map = {
            X = { 87/255, 50/255, 17/255 }, -- Brown for walls
            G = { 58/255, 33/255, 11/255 }, -- Darker Brown for ground
            [' '] = { 0, 0, 0, 0 }           -- Transparent for air
        },
        spawn_tables = {
            L = { 1, 1, 0 },    -- Yellow for loot
            E = { 1, 0, 0 }     -- Red for enemies
        }
    },
    goblin_grotto = {
        asset_map = {
            X = { 50/255, 87/255, 17/255 }, -- Green for walls
            G = { 33/255, 58/255, 11/255 }, -- Darker Green for ground
            [' '] = { 0, 0, 0, 0 }
        },
        spawn_tables = {
            L = { 0, 1, 1 },    -- Cyan for loot
            E = { 1, 0, 1 }     -- Magenta for enemies
        }
    }
}
return biomes
```

-----

## `level_generator.lua`

```lua
local LevelGenerator = {}

-- Generates a sequence of coordinates for the main path
function LevelGenerator.generate_critical_path()
    local path = {}
    local current_pos = { x = math.random(1, 8), y = 1 }
    table.insert(path, {x=current_pos.x, y=current_pos.y})

    local direction = (math.random(2) == 1 and 1 or -1)

    while current_pos.y < 8 do
        local dropped = false
        if math.random() < 0.15 then -- Chance to randomly drop
            current_pos.y = current_pos.y + 1
            dropped = true
        else -- Move horizontally
            local next_x = current_pos.x + direction
            if next_x < 1 or next_x > 8 then -- Hit a wall
                current_pos.y = current_pos.y + 1
                direction = direction * -1
                dropped = true
            else
                current_pos.x = next_x
            end
        end
        table.insert(path, {x=current_pos.x, y=current_pos.y})
    end
    -- You could add logic here for the final horizontal walk on the last row
    return path
end

---
-- Finds all keys in the template library that satisfy the minimum exit requirements.
-- @param constraints (table) e.g., { up = true, right = true }
-- @param all_templates (table) The entire template library, keyed by shape.
-- @return (table) A list of valid keys, e.g., {"U-R", "U-D-R", "U-D-L-R"}
---
function LevelGenerator.find_valid_keys(constraints, all_templates)
    local valid_keys = {}

    -- Loop through every known shape in the library
    for key, _ in pairs(all_templates) do
        -- Check if this shape provides all the required exits
        local is_valid = true
        if constraints.up    and not key:find("U") then is_valid = false end
        if constraints.down  and not key:find("D") then is_valid = false end
        if constraints.left  and not key:find("L") then is_valid = false end
        if constraints.right and not key:find("R") then is_valid = false end

        if is_valid then
            table.insert(valid_keys, key)
        end
    end

    return valid_keys
end


-- Main orchestrator function
function LevelGenerator.generate_level(biome, all_templates)
    -- 1. Generate path and create constraint grid
    local critical_path = LevelGenerator.generate_critical_path()
    local level_grid = {}
    for y = 1, 8 do level_grid[y] = {} end

    for i, pos in ipairs(critical_path) do
        local prev_pos = critical_path[i-1]
        local next_pos = critical_path[i+1]
        local constraints = { up = false, down = false, left = false, right = false }

        if prev_pos then
            if prev_pos.y < pos.y then constraints.up = true end
            if prev_pos.x < pos.x then constraints.left = true end
            if prev_pos.y > pos.y then constraints.down = true end
            if prev_pos.x > pos.x then constraints.right = true end
        end
        if next_pos then
            if next_pos.y > pos.y then constraints.down = true end
            if next_pos.x > pos.x then constraints.right = true end
            if next_pos.y < pos.y then constraints.up = true end
            if next_pos.x < pos.x then constraints.left = true end
        end
        level_grid[pos.y][pos.x] = { required_exits = constraints }
    end

    -- 2. Assemble the level from the grid and templates
    local final_map = {}
    local entities = {}
    local room_width = #all_templates["L-R"][1].tiles[1] -- Get dimensions from a known template
    local room_height = #all_templates["L-R"][1].tiles

    for y = 1, 8 do
        for x = 1, 8 do
            local constraints = (level_grid[y][x] and level_grid[y][x].required_exits) or {}

            -- "Gather and Pick" Selection Logic
            local valid_keys = LevelGenerator.find_valid_keys(constraints, all_templates)
            local possible_rooms_pool = {}
            for _, key in ipairs(valid_keys) do
                if all_templates[key] then
                    for _, variation in ipairs(all_templates[key]) do
                        table.insert(possible_rooms_pool, variation)
                    end
                end
            end

            if #possible_rooms_pool > 0 then
                local template = possible_rooms_pool[math.random(#possible_rooms_pool)]

                -- Instantiate the template using the biome's theme
                for ty, row in ipairs(template.tiles) do
                    local current_room_width = #row
                    for tx, tile_char in ipairs(row) do
                        local map_x, map_y = (x - 1) * room_width + tx, (y - 1) * room_height + ty
                        if not final_map[map_y] then final_map[map_y] = {} end

                        if biome.asset_map[tile_char] then
                             final_map[map_y][map_x] = biome.asset_map[tile_char]
                        elseif biome.spawn_tables[tile_char] then
                            final_map[map_y][map_x] = biome.asset_map[' '] -- Spawn on an air tile
                            table.insert(entities, {
                                type = tile_char,
                                x = (map_x - 1) * 32,
                                y = (map_y - 1) * 32,
                                color = biome.spawn_tables[tile_char]
                            })
                        end
                    end
                end
            end
        end
    end

    return final_map, entities, critical_path, {width = 8 * room_width, height = 8 * room_height}
end

return LevelGenerator
```