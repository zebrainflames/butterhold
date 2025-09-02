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
