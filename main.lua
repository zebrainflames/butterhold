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
    local biomes_list = {"caves", "goblin_grotto"}
    local biome_name = biomes_list[math.random(#biomes_list)]
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
    print("love.load() called")
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
