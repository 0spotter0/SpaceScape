push = require "push"
bullet = require "bullet"
boundingBox = require "boundingbox"

WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()
WINDOW_HEIGHT = WINDOW_HEIGHT - 45
VIRTUAL_WIDTH = WINDOW_WIDTH / 2
VIRTUAL_HEIGHT = WINDOW_HEIGHT / 2
LIVES = 4

ship1 = {
    lives = LIVES,
    sizeX = 32,
    sizeY = 32,
    spawnX = 50,
    spawnY = VIRTUAL_HEIGHT / 2,
    texture = love.graphics.newImage("assets/textures/ship1.png"),
    rotKeyR = "d",
    rotKeyL = "a",
    thrustKey = "space",
    fireKey = "v",
    boundOffset = 2,
    x = 0,
    y = 0,
    dx = 0,
    dy = 0,
    r = math.rad(0),
    dr = 0,
    lastBullet = 0,
}

ship2 = {
    lives = LIVES;
    sizeX = 32,
    sizeY = 32,
    spawnX = VIRTUAL_WIDTH - 50,
    spawnY = VIRTUAL_HEIGHT / 2,
    texture = love.graphics.newImage("assets/textures/ship2.png"),
    rotKeyR = "right",
    rotKeyL = "left",
    thrustKey = "n",
    fireKey = "m",
    lastBullet = 0,
    boundOffset = 2,
    x = 0,
    y = 0,
    dx = 0,
    dy = 0,
    r = 0,
    dr = 0,
    lastBullet = 0,
}

function love.load()
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT)    
    love.graphics.setDefaultFilter("nearest", "nearest")

    ship1.boundingBox = BoundingBox:create(ship1)
    ship2.boundingBox = BoundingBox:create(ship2)
    
    gameState = 'title'
end

function love.update(dt)
    if gameState == 'title' then
        resetGame()
    elseif gameState == 'play' then
        updateShip(ship1, dt)
        updateShip(ship2, dt)
        if table.getn(bulletArray) > 0 then
            for i = 1, table.getn(bulletArray) do
                if(not bulletArray[i].disabled) then
                    -- print(bulletArray[i].index)
                    updateBullet(bulletArray[i], dt)
                end
            end
        end
        if collides(ship1, ship2) then
            respawn(ship1)
            respawn(ship2)
        end
        if ship1.lives <= 0 or ship2.lives <= 0 then
            gameState = 'win'
        end
    elseif gameState == 'win' then
        if love.keyboard.isDown('return') then
            gameState = 'title'
        end
    end 

end

function love.keypressed(key)
    if key == 'r' then
        gameState = 'title'
    elseif key == 'return' then
        gameState = 'play'
    elseif key == 'escape' then
        love.event.quit()
    end
end

function love.draw()
    push:start()

    -- love.graphics.clear(0.1, 0.1, 0.1) -- set custom background color

    if gameState == 'title' then
        love.graphics.setFont(love.graphics.newFont(20))
        love.graphics.print("press enter to start")
    
    elseif gameState == 'play' then
        if table.getn(bulletArray) > 0 then
            for i = 1, table.getn(bulletArray) do
                if not bulletArray[i].disabled then
                    drawBullet(bulletArray[i])
                end
            end
        end
        love.graphics.draw(ship1.texture, ship1.x, ship1.y, ship1.r, 1, 1, 16, 16)
        love.graphics.draw(ship2.texture, ship2.x, ship2.y, ship2.r, 1, 1, 16, 16)
        -- info bar
        INFOBAR_HEIGHT = 25
        love.graphics.setColor(0.1, 0.1, 0.1)
        love.graphics.rectangle("fill", 0, VIRTUAL_HEIGHT - INFOBAR_HEIGHT, VIRTUAL_WIDTH, INFOBAR_HEIGHT)
        -- score display 
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.print('red: ' .. ship1.lives .. ", blue: " .. ship2.lives, 6, VIRTUAL_HEIGHT - INFOBAR_HEIGHT + 5)
        drawBoundingBox(ship1)
        drawBoundingBox(ship2)
        
    elseif gameState == 'win' then
        --display winning screen        
        love.graphics.setFont(love.graphics.newFont(50))
        love.graphics.setColor(1, 1, 1)
        if ship1.lives > ship2.lives then
            love.graphics.print("RED WINS")
        elseif ship1.lives < ship2.lives then
            love.graphics.print("BLUE WINS")
        else
            love.graphics.print("TIE")
        end
    end

    displayFPS()

    push:finish()
end

--[[
    Renders the current FPS.
]]
function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(255, 255, 255, 255)
end

function drawBoundingBox(object)
    box = object.boundingBox
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("line", box.x, box.y, box.sizeX, box.sizeY)
end

function updateBoundingBox(object)
    object.boundingBox.x = (object.x - object.sizeX / 2) + object.boundOffset
    object.boundingBox.y = (object.y - object.sizeY / 2) + object.boundOffset
end

function resetGame()
    bulletArray = {}
    ship1.lives = LIVES
    ship2.lives = LIVES
    respawn(ship1)
    respawn(ship2)
end

function updateShip(ship, dt)
    if love.keyboard.isDown(ship.rotKeyR) then
        ship.r = ship.r + 0.05
    elseif love.keyboard.isDown(ship.rotKeyL) then
        ship.r = ship.r - 0.05
    end

    if love.keyboard.isDown(ship.thrustKey) then
        ship.dx = ship.dx + math.sin(ship.r)*1
        ship.dy = ship.dy - math.cos(ship.r)*1
    end
    
    if love.keyboard.isDown(ship.fireKey) and ship.lastBullet > 0.1 then --cooldown firerate
        bulletArray[table.getn(bulletArray) + 1] = Bullet:create(ship, table.getn(bulletArray))
        -- Bullet:testupdate()
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

    
    if ship.x > VIRTUAL_WIDTH and ship.dx > 0 then
        ship.x = 0
    end
    if ship.x < 0 and ship.dx < 0 then
        ship.x = VIRTUAL_WIDTH
    end
    if ship.y > VIRTUAL_HEIGHT and ship.dy > 0 then
        ship.y = 0
    end
    if ship.y < 0 and ship.dy < 0 then
        ship.y = VIRTUAL_HEIGHT - 9
    end

    
    ship.lastBullet = ship.lastBullet + dt
    ship.x = ship.x + ship.dx * dt
    ship.y = ship.y + ship.dy * dt
    ship.r = ship.r + math.rad(ship.dr) * dt
end

function respawn(ship)
    ship.lives = ship.lives - 1
    ship.x = ship.spawnX
    ship.y = ship.spawnY
    ship.dx = 0
    ship.dy = 0
    ship.r = math.rad(0)
    ship.dr = 0
    ship.lastBullet = 0
end

function updateBullet(bullet, dt)
    bullet.x = bullet.x + bullet.dx * dt
    bullet.y = bullet.y + bullet.dy * dt
    updateBoundingBox(bullet)
    
    if bullet.x < 0 or bullet.x > VIRTUAL_WIDTH or bullet.y < 0 or bullet.y > VIRTUAL_HEIGHT then
        bullet.disabled = true
    end
    if collides(bullet, ship2) and bullet.source == ship1 then
        bullet.disabled = true
        respawn(ship2)
    end
    if collides(bullet, ship1) and bullet.source == ship2 then
        bullet.disabled = true
        respawn(ship1)
    end
end

function drawBullet(bullet)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", bullet.x - (bullet.sizeX / 2), bullet.y - (bullet.sizeY / 2), bullet.sizeX, bullet.sizeY)
end

function collides(thing1, thing2)
    b1 = thing1.boundingBox
    b2 = thing2.boundingBox
    left1 = b1.x
    left2 = b2.x
    right1 = b1.x + b1.sizeX
    right2 = b2.x + b2.sizeX
    top1 = b1.y
    top2 = b2.y
    bottom1 = b1.y + b1.sizeY
    bottom2 = b2.y + b2.sizeY
    
    --if either left or right edge of obj 1 is in between the left and right edges(x-values)of obj 2
    if (left1 > left2 and left1 < right2) or (right1 > left2 and right1 < right2) then
         --if the top or bottom edge is in between the top and bottom edges (y-values) of obj 2
        if (top1 > top2 and top1 < bottom2) or (bottom1 > top2 and bottom1 < bottom2) then
            return true
        end
    end
    return false
end
