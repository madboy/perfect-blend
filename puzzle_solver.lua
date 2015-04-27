local puzzle_solver = {}

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

function puzzle_solver.walk(player, tile)
    puzzle_solver.changeColor(player, tile)
end

function puzzle_solver.solvable(grid, grid_size, player)
    if next(grid) == nil then
        return false
    elseif #grid ~= grid_size then
        return false
    end
    for i = 2,grid_size do
        local tile_id = grid[i]
        local tile = tiles[tile_id]
        puzzle_solver.walk(player, tile)
    end
    return colorsMatch(player)
end

return puzzle_solver
