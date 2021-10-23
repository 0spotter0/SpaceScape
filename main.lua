push = require "push"
WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()
WINDOW_HEIGHT = WINDOW_HEIGHT - 45
VIRTUAL_WIDTH = WINDOW_WIDTH / 2
VIRTUAL_HEIGHT = WINDOW_HEIGHT / 2

function love.load()
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT)    
    love.graphics.setDefaultFilter("nearest", "nearest")

    gameState = 'title'
end

function love.update(dt)

    if gameState == 'title' then
        resetGame()
    elseif gameState == 'play' then
        updateShipMovement(ship1)
        updateShipMovement(ship2)
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

    -- ship.x = ship.x + ship.dx
    -- ship.y = ship.y + ship.dy

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

    -- love.graphics.clear(0.1, 0.1, 0.1)
    
    love.graphics.draw(ship1.texture, ship1.x, ship1.y, ship1.r, 1, 1, 16, 16) --, ship.x, ship.y, ship.direction
    love.graphics.draw(ship2.texture, ship2.x, ship2.y, ship2.r, 1, 1, 16, 16) --, ship.x, ship.y, ship.direction

    -- info bar
    INFOBAR_HEIGHT = 25
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, VIRTUAL_HEIGHT - INFOBAR_HEIGHT, VIRTUAL_WIDTH, INFOBAR_HEIGHT)

    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.setFont(love.graphics.newFont(12))
    -- love.graphics.setColor(76/255, 77/255, 89/255, 255/255)
    love.graphics.print('state: ' .. gameState, 6, VIRTUAL_HEIGHT - INFOBAR_HEIGHT + 5)
        
    push:finish()
end

function resetGame()
    score1 = 0
    score2 = 0
    ship1 = {}
    ship1.x = 50
    ship1.y = VIRTUAL_HEIGHT / 2
    ship1.dx = 0
    ship1.dy = 0
    ship1.r = toRad(0)
    ship1.dr = 0
    ship1.texture = love.graphics.newImage("assets/textures/ship1.png")
    ship1.rotKeyR = "d"
    ship1.rotKeyL = "a"
    ship1.thrustKey = "space"

    ship2 = {}
    ship2.x = VIRTUAL_WIDTH - 50
    ship2.y = VIRTUAL_HEIGHT / 2
    ship2.dx = 0
    ship2.dy = 0
    ship2.r = toRad(0)
    ship2.dr = 0
    ship2.texture = love.graphics.newImage("assets/textures/ship2.png")
    ship2.rotKeyR = "right"
    ship2.rotKeyL = "left"
    ship2.thrustKey = "m"
end

function toRad(degrees)
    return degrees * (math.pi/180)
end

function updateShipMovement(ship)
    if love.keyboard.isDown(ship.rotKeyR) then
        ship.r = ship.r + 0.015
    elseif love.keyboard.isDown(ship.rotKeyL) then
        ship.r = ship.r - 0.015
    end

    if love.keyboard.isDown(ship.thrustKey) then
        ship.dx = ship.dx + math.sin(ship.r)*0.01
        ship.dy = ship.dy - math.cos(ship.r)*0.01
    end
    ship.x = ship.x + ship.dx
    ship.y = ship.y + ship.dy
    ship.r = ship.r + toRad(ship.dr)
end