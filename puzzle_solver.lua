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

function getNewColor(current, new)
    local mix = {r=nil, g=nil, b=nil}
    mix.r = (current.r + new.r) * 0.5
    mix.g = (current.g + new.g) * 0.5
    mix.b = (current.b + new.b) * 0.5
    return mix
end

function puzzle_solver.changeColor(p, tile)
    local new = getNewColor(p, tile)
    p.r = new.r
    p.g = new.g
    p.b = new.b
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

function puzzle_solver.getMarkerPosition(grid, marker)
    local pos = 0
    for i, t in pairs(grid) do
        if t == marker then
            return i
        end
    end
    return pos
end

function getPlayerPosition(grid)
    return puzzle_solver.getMarkerPosition(grid, "@")
end

function getExitPosition(grid)
    return puzzle_solver.getMarkerPosition(grid, "e")
end

function getTile(n, gn, grid)
    local i = puzzle_solver.getMarkerPosition(gn, n)
    assert(i ~= 0, "tile not found: " .. n)
    local tile_id = grid[i]
    return tiles[tile_id], i
end

function puzzle_solver.getNextStep(player, pos, exit, grid_numbers, grid_describer)
    -- returns the index of the next step
    -- we should take
    local gn = grid_numbers[pos]
    local en = grid_numbers[exit]
    local paths = grid_describer[gn]

    -- if the exit is in our paths then we should go there
    -- as this both let's us exit and takes us closer
    -- to the exit color
    for _, path in pairs(paths) do
        if path == en then
            return path
        end
    end

    -- checking if the next color will be closer to the exit
    -- color is a hassle at the moment. the whole grid description
    -- makes it super hard. Fix it first!
    --local closest_color_match = 0
    --for _, path in pairs(paths) do
    --    puzzle_solver.changeColor(player, tile)
    --end
    -- l.member(exit, paths) and colorsMatch()
    -- if so go to the exit
    -- ? get closer to the exit ?
    -- min(paths - exit)
    -- ? can we get closer to exit color ?
    -- min(changeColor paths - exit)
    -- ? go in random direction ?
    -- random(paths)
    return l.max(paths)

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
    local precheck, msg = preChecks(grid, grid_size)
    local position = getPlayerPosition(grid)
    local exit = getExitPosition(grid)
    if precheck then
        local grid_numbers = {}
        local grid_describer = {}
        grid_numbers, grid_describer = puzzle_solver.getGridNumbers(grid, grid_size)
        local steps = 0

        while steps < 10 and (not colorsMatch(player)) do
            steps = steps + 1
            local destination = puzzle_solver.getNextStep(player, position, exit, grid_numbers, grid_describer)
            local tile, idx = getTile(destination, grid_numbers, grid)

            puzzle_solver.walk(player, tile)

            position = idx
        end
        return colorsMatch(player)
    else
        if debug then print(msg) end
        return false
    end
end

return puzzle_solver
