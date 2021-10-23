push = require "push"
bullet = require "bullet"
boundingBox = require "boundingbox"

WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()
WINDOW_HEIGHT = WINDOW_HEIGHT - 45
VIRTUAL_WIDTH = WINDOW_WIDTH / 2
VIRTUAL_HEIGHT = WINDOW_HEIGHT / 2

ship1 = {}
ship2 = {}

-- ship1 = {
--     score = 0
--     x = 50
--     y = VIRTUAL_HEIGHT / 2
--     dx = 0
--     dy = 0
--     r = math.rad(0)
--     dr = 0
--     texture = love.graphics.newImage("assets/textures/ship1.png")
--     rotKeyR = "d"
--     rotKeyL = "a"
--     thrustKey = "space"
-- }

-- ship2 = {
--     score = 0
--     x = VIRTUAL_WIDTH - 50
--     y = VIRTUAL_HEIGHT / 2
--     dx = 0
--     dy = 0
--     r = math.rad(0)
--     dr = 0
--     texture = love.graphics.newImage("assets/textures/ship2.png")
--     rotKeyR = "right"
--     rotKeyL = "left"
--     thrustKey = "m"
-- }

function love.load()
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT)    
    love.graphics.setDefaultFilter("nearest", "nearest")
    gameState = 'title'
end

function love.update(dt)

    if gameState == 'title' then
        resetGame()
    elseif gameState == 'play' then
        updateShip(ship1, dt)
        updateShip(ship2, dt)
        if score1 >= winScore or score2 > winScore then
            gameState = 'win'
        end
    elseif gameState == 'win' then
        --TODO: make ships dissappear and show winning screen
        if score1 > score2 then
            love.graphics.printf() --TODO: declare winner: Player 1
        else
            love.graphics.printf() --TODO: declare winner: Player 2
        end
        if love.keypressed.isDown('return') then
            gameState = 'title'
        end
    end 
    
    if table.getn(bulletArray) > 0 then
        for i = 1, table.getn(bulletArray) do
            updateBullet(bulletArray[i], dt) 
        end
    end

    if collides(ship1, ship2) then
        gameState = 'title'
    end

end

function love.keypressed(key)
    if key == '1' then
        gameState = 'title'
    elseif key == 'return' then
        gameState = 'play'
    elseif key == 'escape' then
        love.event.quit()
    -- elseif key == 'f' then
    --     if love.window.getFullscreen() then
    --         push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {fullscreen = false})
    --     else
    --         push:setupScreen(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {fullscreen = true})
    --     end
    --     -- love.window.setFullscreen(not love.window.getFullscreen())
    end

end

function love.draw()
    push:start()

    -- love.graphics.clear(0.1, 0.1, 0.1) -- set custom background color

    if table.getn(bulletArray) > 0 then
        for i = 1, table.getn(bulletArray) do
            drawBullet(bulletArray[i]) 
        end
    end

    love.graphics.draw(ship1.texture, ship1.x, ship1.y, ship1.r, 1, 1, 16, 16)
    love.graphics.draw(ship2.texture, ship2.x, ship2.y, ship2.r, 1, 1, 16, 16)

    -- info bar
    INFOBAR_HEIGHT = 25
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, VIRTUAL_HEIGHT - INFOBAR_HEIGHT, VIRTUAL_WIDTH, INFOBAR_HEIGHT)

    -- game state display display
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print('state: ' .. gameState, 6, VIRTUAL_HEIGHT - INFOBAR_HEIGHT + 5)

    drawBoundingBox(ship1)
    drawBoundingBox(ship2)

    push:finish()
end

function drawBoundingBox(object)
    box = object.boundingBox
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("line", box.x, box.y, box.size, box.size)
end

function updateBoundingBox(object)
    object.boundingBox.x = (object.x - object.size / 2) + object.boundOffset
    object.boundingBox.y = (object.y - object.size / 2) + object.boundOffset
end

function resetGame()
    winScore = 7
    bulletArray = {}

    score1 = 0
    score2 = 0
    ship1.size = 32
    ship1.x = 50
    ship1.y = VIRTUAL_HEIGHT / 2
    ship1.dx = 0
    ship1.dy = 0
    ship1.r = math.rad(0)
    ship1.dr = 0
    ship1.texture = love.graphics.newImage("assets/textures/ship1.png")
    ship1.rotKeyR = "d"
    ship1.rotKeyL = "a"
    ship1.thrustKey = "space"
    ship1.fireKey = "v"
    ship1.lastBullet = 0
    ship1.boundOffset = 2
    ship1.boundingBox = BoundingBox:create(ship1)

    ship2.size = 32
    ship2.x = VIRTUAL_WIDTH - 50
    ship2.y = VIRTUAL_HEIGHT / 2
    ship2.dx = 0
    ship2.dy = 0
    ship2.r = math.rad(0)
    ship2.dr = 0
    ship2.texture = love.graphics.newImage("assets/textures/ship2.png")
    ship2.rotKeyR = "right"
    ship2.rotKeyL = "left"
    ship2.thrustKey = "n"
    ship2.fireKey = "m"
    ship2.lastBullet = 0
    ship2.boundOffset = 2
    ship2.boundingBox = BoundingBox:create(ship2)
end

function drawBullet(bullet)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", bullet.x - 1, bullet.y - 1, 3, 3)
end

function updateShip(ship, dt)
    if love.keyboard.isDown(ship.rotKeyR) then
        ship.r = ship.r + 0.07
    elseif love.keyboard.isDown(ship.rotKeyL) then
        ship.r = ship.r - 0.07
    end

    if love.keyboard.isDown(ship.thrustKey) then
        ship.dx = ship.dx + math.sin(ship.r)*1
        ship.dy = ship.dy - math.cos(ship.r)*1
    end
    
    if love.keyboard.isDown(ship.fireKey) and ship.lastBullet > .2 then
        bulletArray[table.getn(bulletArray) + 1] = Bullet:create(ship)
        ship.lastBullet = 0
    end

    -- if love.keyboard.isDown('right') then
    --     ship.dr = ship.dr + 0.01
    -- elseif love.keyboard.isDown('left') then
    --     ship.dr = ship.dr - 0.01
    -- else
    --     if ship.dr > 0 then
    --         ship.dr = ship.dr - 0.25
    --     elseif ship.dr < 0 then
    --         ship.dr = ship.dr + 0.25
    --     end
    -- end
    updateBoundingBox(ship)

    ship.lastBullet = ship.lastBullet + dt
    ship.x = ship.x + ship.dx * dt
    ship.y = ship.y + ship.dy * dt
    ship.r = ship.r + math.rad(ship.dr)
end

function updateBullet(bullet, dt)
    bullet.x = bullet.x + bullet.dx * dt
    bullet.y = bullet.y + bullet.dy * dt
end

function collides(thing1, thing2)
    b1 = thing1.boundingBox
    b2 = thing2.boundingBox
    left1 = b1.x 
    left2 = b2.x 
    right1 = b1.x + b1.size
    right2 = b1.x + b2.size
    top1 = b1.y
    top2 = b2.y
    bottom1 = b1.y + b1.size
    bottom2 = b2.y + b2.size
    
    --if either left or right edge of obj 1 is in between the left and right edges of obj 2
    if (left1 > left2 and left1 < right2) or (right1 > left2 and right1 < right2) then
         --if the top or bottom edge is in between the top and bottom edges of obj 2
        if (top1 < top2 and top1 > bottom2) or (top1 < top2 and top1 > bottom2) then
            return true
        end
    end
    return false
end