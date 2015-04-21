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
                    b=c.violet_blue.b}}
local grid = {}
local p = {}
local player_tile = {}
local e = {}

local level1 = {2,1,"e",1,2,
                2,1,1,1,2,
                2,2,2,2,2,
                2,2,2,2,2,
                2,2,"@",2,2}

local level2 = {2,2,"e",2,2,
                2,2,2,2,2,
                2,2,2,2,2,
                2,2,3,2,2,
                2,2,"@",4,2}

local tile_set = {}

local state = "game"
local player_state = "start"

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

function setPlayerTile(r, g, b)
    player_tile = {r=r, g=g, b=b}
end

function changeColor()
    if player_state == "start" then return end
    p.r = (p.r + player_tile.r)*0.5
    p.g = (p.g + player_tile.g)*0.5
    p.b = (p.b + player_tile.b)*0.5
end

function canExit()
    if p.x == e.x and
        p.y == e.y then
        return true
    end
    return false
end

function loadNextLevel(l)
    grid = createGrid(grids, tile_size)
    tile_set = createTiles(grid, l)
    player_state = "start"
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if key == "up" and p.y > 0 then
        p.y = p.y - tile_size
        player_state = "moving"
        changeColor()
    end
    if key == "down" and p.y < (grids-1)*tile_size then
        p.y = p.y + tile_size
        player_state = "moving"
        changeColor()
    end
    if key == "right" and p.x < (grids-1)*tile_size then
        p.x = p.x + tile_size
        player_state = "moving"
        changeColor()
    end
    if key == "left" and p.x > 0 then
        p.x = p.x - tile_size
        player_state = "moving"
        changeColor()
    end
    if key == "l" and player_state == "can_exit" then
        loadNextLevel(level2)
    end
end

function love.load()
    grid = createGrid(grids, tile_size)
    tile_set = createTiles(grid, level1)
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
    for _, tile in ipairs(tile_set) do
        love.graphics.setColor(tile.r, tile.g, tile.b)
        love.graphics.rectangle("fill", tile.x, tile.y, tile_size, tile_size)

        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("line", tile.x, tile.y, tile_size, tile_size)

        if tile.type == "exit" then
            love.graphics.print("exit", tile.x, tile.y)
        end

        if p.x == tile.x and
            p.y == tile.y then
            setPlayerTile(tile.r, tile.g, tile.b)
        end
    end

    love.graphics.setColor(p.r, p.g, p.b)
    love.graphics.rectangle("fill", p.x, p.y, tile_size, tile_size)

    if player_state == "can_exit" then
        love.graphics.setColor(0,0,0)
        love.graphics.print("E", p.x, p.y)
    end
end
