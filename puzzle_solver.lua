local puzzle_solver = {}

local l = require("list")

local debug = false

local c = {yellow = {r=255, g=255, b=0},
          yellow_orange = {r=255, g=204, b=0},
          green_yellow = {r=160, g=255, b=32},
          red_violet = {r=244, g=62, b=113},
          violet_blue = {r=76, g=80, b=169},
          white = {r=255, g=255, b=255}}

local tiles = {["e"]={type="exit",
                      r=c.green_yellow.r,
                      g=c.green_yellow.g,
                      b=c.green_yellow.b},
               ["@"]={type="player",
                      r=c.white.r,
                      g=c.white.g,
                      b=c.white.b},
               [1]={type="ground",
                    r=c.green_yellow.r,
                    g=c.green_yellow.g,
                    b=c.green_yellow.b},
               [2]={type="ground",
                    r=c.yellow_orange.r,
                    g=c.yellow_orange.g,
                    b=c.yellow_orange.b},
               [3]={type="ground",
                    r=c.red_violet.r,
                    g=c.red_violet.g,
                    b=c.red_violet.b},
               [4]={type="ground",
                    r=c.violet_blue.r,
                    g=c.violet_blue.g,
                    b=c.violet_blue.b},
               [5]={type="resistance",
                    r=c.white.r,
                    g=c.white.g,
                    b=c.white.b},
               [6]={type="speed",
                    r=c.red_violet.r,
                    g=c.red_violet.g,
                    b=c.red_violet.b}}

local exit = tiles["e"]

function puzzle_solver.changeColor(p, tile)
    p.r = (p.r + tile.r)*0.5
    p.g = (p.g + tile.g)*0.5
    p.b = (p.b + tile.b)*0.5
end

function withinLimit(v1, v2)
    return (math.abs(v1 - v2) < 10)
end

function colorsMatch(p)
    return withinLimit(p.r, exit.r) and
           withinLimit(p.g, exit.g) and
           withinLimit(p.b, exit.b)
end

function puzzle_solver.getGridNumbers(grid, grid_size)
    -- generates a numbering for each tile in the grid, gn
    -- for each tile we save which tiles are accessible from it, gd
    local gn = {}
    local gd = {}
    local rows = #grid / grid_size
    for row = 1,rows do
        for i = 1,grid_size do
            local describer = i+10*row
            local description = {}
            table.insert(gn, describer)
            if i == 1 then
                table.insert(description, describer+1)
            elseif i == grid_size then
                table.insert(description, describer-1)
            else
                table.insert(description, describer-1)
                table.insert(description, describer+1)
            end
            if rows > 1 then
                if row == 1 then
                    table.insert(description, describer+10)
                elseif row == rows then
                    table.insert(description, describer-10)
                else
                    table.insert(description, describer-10)
                    table.insert(description, describer+10)
                end
            end
            gd[describer] = description
        end
    end
    return gn, gd
end

function getMarkerPosition(grid, marker)
    local pos = 0
    for i, t in pairs(grid) do
        if t == marker then
            pos = i
            return pos
        end
    end
    return pos
end

function getPlayerPosition(grid)
    return getMarkerPosition(grid, "@")
end

function getExitPosition(grid)
    return getMarkerPosition(grid, "e")
end

function getTile(n, gn, grid)
    for i,v in ipairs(gn) do
        if v == n then
            local tile_id = grid[i]
            return tiles[tile_id], i
        end
    end
    return nil
end

-- for now this will be a walk forward strategy
-- only considering another way if we cannot go any
-- further
function puzzle_solver.walk(player, tile)
    puzzle_solver.changeColor(player, tile)
end

function printNestedTable(t)
    for i,v in ipairs(t) do
        print(table.unpack(v))
    end
end

function preChecks(grid, grid_size)
    -- pre checks to see if base criteria for the grid
    -- is fulfilled
    if next(grid) == nil then
        return false, "empty grid"
    elseif (#grid % grid_size) ~= 0 then
        return false, "grid size mismatch"
    end
    if getPlayerPosition(grid) == 0 then
        return false, "no player present"
    end
    if getExitPosition(grid) == 0 then
        return false, "no exit present"
    end
    local tile_index = l.get_indexes(tiles)
    for _,v in ipairs(grid) do
        if not l.member(v, tile_index) then
            return false, "unknown tiles"
        end
    end
    return true
end

function puzzle_solver.solvable(grid, grid_size, player)
    local position = getPlayerPosition(grid)
    local precheck, msg = preChecks(grid, grid_size)
    if  precheck then
        local grid_numbers = {}
        local grid_describer = {}
        grid_numbers, grid_describer = puzzle_solver.getGridNumbers(grid, grid_size)
        local steps = 0

        while steps < 10 and (not colorsMatch(player)) do
            steps = steps + 1
            local gn = grid_numbers[position]
            local paths = grid_describer[gn]
            local destination = l.max(paths)
            local tile, idx = getTile(destination, grid_numbers, grid)

            puzzle_solver.walk(player, tile)

            --[[
            if idx < position then
            print("Hey, I'm going backwards")
            else
            print("Ohh, fwd it is")
            end
            ]]
            position = idx
        end
        return colorsMatch(player)
    else
        if debug then print(msg) end
        return false
    end
end

return puzzle_solver
