grids = 5
tile_size = 60

local c = {yellow = {r=255, g=255, b=0},
          yellow_orange = {r=255, g=204, b=0},
          green_yellow = {r=160, g=255, b=32},
          white = {r=255, g=255, b=255}}

local grid = {}
local p = {x=120, y=240}
local e = {x=120, y=0}

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

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if key == "up" and p.y > 0 then
        p.y = p.y - tile_size
    end
    if key == "down" and p.y < (grids-1)*tile_size then
        p.y = p.y + tile_size
    end
    if key == "right" and p.x < (grids-1)*tile_size then
        p.x = p.x + tile_size
    end
    if key == "left" and p.x > 0 then
        p.x = p.x - tile_size
    end
end

function love.load()
    grid = createGrid(5, 60)
end

function love.draw()
    for _, tile in ipairs(grid) do
        love.graphics.setColor(c.yellow_orange.r,
        c.yellow_orange.g,
        c.yellow_orange.b)
        love.graphics.rectangle("fill", tile.x, tile.y, tile_size, tile_size)
    end
    love.graphics.setColor(c.green_yellow.r, c.green_yellow.g, c.green_yellow.b)
    love.graphics.rectangle("fill", e.x, e.y, tile_size, tile_size)

    love.graphics.setColor(c.white.r, c.white.g, c.white.b)
    love.graphics.rectangle("fill", p.x, p.y, tile_size, tile_size)
end
