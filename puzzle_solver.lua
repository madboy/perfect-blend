local puzzle_solver = {}

local l = require("list")

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

-- only works for 1d grid at the moment
function getGridNumbers(grid)
    local gn = {}
    local gd = {}
    for i in ipairs(grid) do
        local describer = i+10
        table.insert(gn, describer)
        if i == 1 then
            gd[describer] = {describer+1}
        elseif i == #grid then
            gd[describer] = {describer-1}
        else
            gd[describer] ={describer-1, describer+1}
        end
    end
    return gn, gd
end

function getPlayerPosition(grid)
    local pos = 0
    for i, t in pairs(grid) do
        if t == "@" then
            pos = i
            return pos
        end
    end
    return pos
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

function puzzle_solver.solvable(grid, grid_size, player)
    -- pre checks to see if base criteria for the grid
    -- is fulfilled
    if next(grid) == nil then
        return false
    elseif #grid ~= grid_size then
        return false
    end
    local position = getPlayerPosition(grid)
    if position == 0 then
        return false
    end

    local grid_numbers = {}
    local grid_describer = {}
    grid_numbers, grid_describer = getGridNumbers(grid)
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
end

return puzzle_solver
