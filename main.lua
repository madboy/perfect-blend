grids = 5
tile_size = 60

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
local grid = {}
local p = {}
local player_tile = {}
local immunity = 0
local speed = 1
local speed_duration = 0
local e = {}

local level1 = {2,1,"e",1,2,
                2,1,1,1,2,
                2,2,2,2,2,
                2,2,2,2,2,
                2,2,"@",2,2}

local level2 = {2,2,"e",2,2,
                2,2,2,2,2,
                2,2,2,2,2,
                2,2,5,2,2,
                2,2,"@",2,2}

local level3 = {1,2,"e",2,2,
                2,2,2,2,2,
                1,2,2,2,2,
                2,2,2,2,2,
                1,2,6,"@",2}

local level4 = {2,2,"e",2,2,
                2,2,2,2,2,
                2,2,1,2,6,
                2,2,2,2,2,
                2,2,"@",2,5}

local levels = {level1, level2, level3, level4}
local level = 1
local tile_set = {}

local state = "game"
local player_state = "start"

local debug = false

function createGrid(n, ts)
    local grid = {}
    for i = 0,n-1 do
        for ii = 0,n-1 do
            local x = ii*ts
            local y = i*ts
            table.insert(grid, {x=x, y=y})
        end
    end
    return grid
end

function createTiles(g, t)
    local tmp_tiles = {}
    for i, tile in ipairs(t) do
        if tile == "@" then
            p.x = g[i].x
            p.y = g[i].y
            p.r = tiles[tile].r
            p.g = tiles[tile].g
            p.b = tiles[tile].b
            tile = 2 -- setting tile to ground so that the color will be correct when we move
        elseif tile == "e" then
            e.x = g[i].x
            e.y = g[i].y
            e.r = tiles[tile].r
            e.g = tiles[tile].g
            e.b = tiles[tile].b
        end
        table.insert(tmp_tiles, {type=tiles[tile].type,
                                 x=g[i].x,
                                 y=g[i].y,
                                 r=tiles[tile].r,
                                 g=tiles[tile].g,
                                 b=tiles[tile].b})
    end
    return tmp_tiles
end

function getPlayerTile()
    for _, tile in ipairs(tile_set) do
        if p.x == tile.x and
            p.y == tile.y then
            setPlayerTile(tile.r, tile.g, tile.b, tile.type)
        end
    end
end

function setPlayerTile(r, g, b, type)
    player_tile = {r=r, g=g, b=b}
    if type == "resistance" then
        immunity = 4
    end
    if type == "speed" then
        speed = 2
        speed_duration = 4
    end
end

function changeColor()
    if player_state == "start" then return end
    if immunity > 0 then immunity = immunity - 1; return end
    if speed_duration > 0 then
        speed_duration = speed_duration - 1
    elseif speed_duration == 0 then
        speed = 1
    end
    p.r = (p.r + player_tile.r)*0.5
    p.g = (p.g + player_tile.g)*0.5
    p.b = (p.b + player_tile.b)*0.5
end

function withinLimit(v1, v2)
    return (math.abs(v1 - v2) < 10)
end

function colorsMatch()
    return withinLimit(p.r, e.r) and
           withinLimit(p.g, e.g) and
           withinLimit(p.b, e.b)
end

function colorWhite()
    return withinLimit(p.r, 255) and
           withinLimit(p.g, 255) and
           withinLimit(p.b, 255)
end

function printTileColor(r, g, b, x, y)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(string.format("%d", r), x + (tile_size - 25), y + (tile_size - 45))
    love.graphics.print(string.format("%d", g), x + (tile_size - 25), y + (tile_size - 30))
    love.graphics.print(string.format("%d", b), x + (tile_size - 25), y + (tile_size - 15))
end

function canExit()
    if (p.x == e.x and
        p.y == e.y)  and
        (colorsMatch() or colorWhite()) then
        return true
    end
    return false
end

function loadLevel(l)
    grid = createGrid(grids, tile_size)
    tile_set = createTiles(grid, l)
    player_state = "start"
    immunity = 0
    speed = 1
    speed_duration = 0
end

function restartLevel()
    loadLevel(levels[level])
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if key == "up" and p.y > 0 then
        p.y = p.y - tile_size * speed
        player_state = "moving"
        getPlayerTile()
        changeColor()
    end
    if key == "down" and p.y < (grids-1)*tile_size then
        p.y = p.y + tile_size * speed
        player_state = "moving"
        getPlayerTile()
        changeColor()
    end
    if key == "right" and p.x < (grids-1)*tile_size then
        p.x = p.x + tile_size * speed
        player_state = "moving"
        getPlayerTile()
        changeColor()
    end
    if key == "left" and p.x > 0 then
        p.x = p.x - tile_size * speed
        player_state = "moving"
        getPlayerTile()
        changeColor()
    end
    if key == "l" and player_state == "can_exit" then
        level = level + 1
        if level > #levels then
            state = "gameover"
        else
            loadLevel(levels[level])
        end
    end
    if key == "r" then
        restartLevel()
    end
    if key == "d" then
        debug = not debug
    end
end

function love.load()
    love.graphics.setBackgroundColor(115, 115, 115)
    grid = createGrid(grids, tile_size)
    tile_set = createTiles(grid, levels[level])
end

function love.update(dt)
    if player_state == "start" then return end
    if canExit() then
        player_state = "can_exit"
    else
        player_state = "moving"
    end
end

function love.draw()
    if state == "gameover" then
        love.graphics.setColor(0,0,0)
        love.graphics.print("Game over", grids*0.33*tile_size, grids*0.5*tile_size)
        love.graphics.print("press esc to leave game", grids*0.33*tile_size, grids*0.5*tile_size+10)
    else
        for _, tile in ipairs(tile_set) do
            love.graphics.setColor(tile.r, tile.g, tile.b)
            love.graphics.rectangle("fill", tile.x, tile.y, tile_size, tile_size)

            love.graphics.setColor(0,0,0)
            love.graphics.rectangle("line", tile.x, tile.y, tile_size, tile_size)

            if tile.type == "exit" then
                love.graphics.print("exit", tile.x, tile.y)
                if debug then printTileColor(tile.r, tile.g, tile.b, tile.x, tile.y) end
            end
        end

        love.graphics.setColor(p.r, p.g, p.b)
        love.graphics.rectangle("fill", p.x, p.y, tile_size, tile_size)

        love.graphics.setColor(0,0,0)
        if debug then love.graphics.print(immunity, p.x, p.y + (tile_size-15)) end
        if debug then love.graphics.print(speed, p.x, p.y + (tile_size-30)) end
        if debug then printTileColor(p.r, p.g, p.b, p.x, p.y) end

        if player_state == "can_exit" then
            love.graphics.setColor(0,0,0)
            love.graphics.print("E", p.x, p.y)
        end
    end
end
