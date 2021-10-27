push = require "push"
bullet = require "bullet"
boundingBox = require "boundingbox"

WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()
WINDOW_HEIGHT = WINDOW_HEIGHT - 45
VIRTUAL_WIDTH = WINDOW_WIDTH / 2
VIRTUAL_HEIGHT = WINDOW_HEIGHT / 2
LIVES = 4
FONT = love.graphics.newFont('assets/fonts/font.TTF', 20, 'normal', 4)
FONT_LARGE = love.graphics.newFont('assets/fonts/font.TTF', 60, 'normal', 4)
FONT_MEDIUM = love.graphics.newFont('assets/fonts/font.TTF', 35, 'normal', 4)
FONT_SMALL = love.graphics.newFont('assets/fonts/font.TTF', 14, 'normal', 4)
COLOR_REDTEXT = {204/255, 0, 0}
COLOR_BLUETEXT = {60/255, 120/255, 216/255}
EXPLOSION_DURATION = 0.3
MAX_ROTATION_SPEED = 400

backgrounds = {
    love.graphics.newImage('assets/textures/background1.png'),
    love.graphics.newImage('assets/textures/background2.png'),
    love.graphics.newImage('assets/textures/background3.png')
}

sounds = {
    ['hit'] = love.audio.newSource('assets/sounds/hit.wav', 'static'),
    ['die'] = love.audio.newSource('assets/sounds/die.wav', 'static'),
    ['shot1'] = love.audio.newSource('assets/sounds/shot1.wav', 'static'),
    ['music'] = love.audio.newSource('assets/sounds/music.mp3', 'stream'),
    ['music1'] = love.audio.newSource('assets/sounds/music1.mp3', 'stream'),
    ['title'] = love.audio.newSource('assets/sounds/title.mp3', 'stream')
}

ship1 = {
    thrust = false,
    lives = LIVES,
    sizeX = 32,
    sizeY = 32,
    spawnX = 50,
    spawnY = VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 7,
    texture = love.graphics.newImage("assets/textures/ship1.png"),
    rotKeyR = "d",
    rotKeyL = "a",
    thrustKey = "w",
    fireKey = "space",
    boundOffset = 2,
    x = 0,
    y = 0,
    dx = 0,
    dy = 0,
    r = 0,
    dr = 0,
    spawnR = 45,
    lastBullet = 0,
    exploding = false,
    explodeTimer = EXPLOSION_DURATION
}

ship2 = {
    thrust = false,
    lives = LIVES,
    sizeX = 32,
    sizeY = 32,
    spawnX = VIRTUAL_WIDTH - 50,
    spawnY = VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 7,
    texture = love.graphics.newImage("assets/textures/ship2.png"),
    rotKeyR = "right",
    rotKeyL = "left",
    thrustKey = "up",
    fireKey = ",",
    lastBullet = 0,
    boundOffset = 2,
    x = 0,
    y = 0,
    dx = 0,
    dy = 0,
    r = 0,
    dr = 0,
    spawnR = -45,
    lastBullet = 0,
    exploding = false,
    explodeTimer = EXPLOSION_DURATION
}

function love.load()
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT)    
    background = nil
    showFPS = false
    love.graphics.setFont(FONT)
    love.graphics.setDefaultFilter("nearest", "nearest")
    math.randomseed(os.time())
    ship1.boundingBox = BoundingBox:create(ship1)
    ship2.boundingBox = BoundingBox:create(ship2)
    thrustTexture = love.graphics.newImage('assets/textures/thrust.png')
    explosionTexture = love.graphics.newImage("assets/textures/explosion.png")
    gameState = 'title'
end

function love.update(dt)
    if gameState == 'title' then
        background = nil
        if sounds['music']:isPlaying() then
            sounds['music']:stop()
        elseif sounds['music1']:isPlaying() then
            sounds['music1']:stop()
        end
        if not sounds['title']:isPlaying() then
            love.audio.play(sounds['title'])
        end
        resetGame()
        
    elseif gameState == 'play' then
        if sounds['title']:isPlaying() then
            sounds['title']:stop()
        end
        if not sounds['music']:isPlaying() and not sounds['music1']:isPlaying() then
            if math.random(0,1) == 1 then
                sounds['music']:setLooping(true)
                sounds['music']:play()
            else
                sounds['music1']:setLooping(true)
                sounds['music1']:play()
            end
        end

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

        if collides(ship1, ship2) and ((not ship1.exploding) and (not ship2.exploding)) then
            sounds['hit']:play()
            explode(ship1)
            explode(ship2)
            -- respawn(ship1)
            -- respawn(ship2)
        end

        if ship1.lives <= 0 or ship2.lives <= 0 then
            sounds['die']:play()
            gameState = 'win'
        end
    elseif gameState == 'win' then
        if love.keyboard.isDown('return') then
            gameState = 'title'
        end
    end 

end

function love.keypressed(key)
    if key == 'escape' then
        if gameState == 'title' then
            love.event.quit()
        elseif gameState == 'play' or gameState == 'win' then
            gameState = 'title'
        end
    elseif key == 'return' then
        if gameState == 'title' then
            gameState = 'play'
        elseif gameState == 'win' then
            gameState = 'title'
        end
    elseif key == '8' then
        showFPS = not showFPS
    end
end

function love.draw()
    push:start()
    -- love.graphics.clear(0, 0, 0) -- set custom solid background color

    if gameState == 'title' then
        love.graphics.setFont(FONT_LARGE)
        love.graphics.printf( "SPACESCAPE", 0, VIRTUAL_HEIGHT/3, VIRTUAL_WIDTH , 'center')
        love.graphics.setFont(FONT_SMALL)
        love.graphics.printf( "CTRLS      ROTATE       THRUST     FIRE", 0, VIRTUAL_HEIGHT/3 + 65, VIRTUAL_WIDTH , 'center');
        love.graphics.printf( "P1                      A   D                     W                SPACE", 0, VIRTUAL_HEIGHT/3 + 85, VIRTUAL_WIDTH , 'center')
        love.graphics.printf( "P2          LEFT RIGHT       UP            COMMA", 0, VIRTUAL_HEIGHT/3 + 105, VIRTUAL_WIDTH , 'center')
        love.graphics.printf( "PRESS  ENTER  TO  START", 0, VIRTUAL_HEIGHT - 65, VIRTUAL_WIDTH , 'center')
        love.graphics.printf( "PRESS  ESC  TO  QUIT", 0, VIRTUAL_HEIGHT - 45, VIRTUAL_WIDTH , 'center')
    elseif gameState == 'play' then
        if background == nil then
            background = backgrounds[math.random(1, table.getn(backgrounds))]
        end
        love.graphics.draw(background, 0, 0, 0, WINDOW_WIDTH / 2560)
        if table.getn(bulletArray) > 0 then
            for i = 1, table.getn(bulletArray) do
                if not bulletArray[i].disabled then
                    drawBullet(bulletArray[i])
                end
            end
        end

        love.graphics.setColor(1, 1, 1)
        if not ship1.exploding then
            if ship1.thrust == true then
                love.graphics.draw(thrustTexture, ship1.x, ship1.y, ship1.r, 1, 1, 8, -14)
            end
            love.graphics.draw(ship1.texture, ship1.x, ship1.y, ship1.r, 1, 1, 16, 16)
        else
            love.graphics.draw(explosionTexture, ship1.x, ship1.y, 0, 1, 1, 16, 16)
        end
        if not ship2.exploding then
            if ship2.thrust == true then
                love.graphics.draw(thrustTexture, ship2.x, ship2.y, ship2.r, 1, 1, 8, -14)
            end
            love.graphics.draw(ship2.texture, ship2.x, ship2.y, ship2.r, 1, 1, 16, 16)
        else
            love.graphics.draw(explosionTexture, ship2.x, ship2.y, 0, 1, 1, 16, 16)
        end

        -- info bar
        INFOBAR_HEIGHT = 30
        love.graphics.setColor(0.1, 0.1, 0.1)
        love.graphics.rectangle("fill", 0, VIRTUAL_HEIGHT - INFOBAR_HEIGHT, VIRTUAL_WIDTH, INFOBAR_HEIGHT)
        -- score display 
        love.graphics.setFont(FONT_MEDIUM)
        love.graphics.setColor(COLOR_REDTEXT)
        love.graphics.printf(tostring(ship1.lives), 37, VIRTUAL_HEIGHT - INFOBAR_HEIGHT - 4, 50, 'left')
        love.graphics.setColor(COLOR_BLUETEXT) --blue
        love.graphics.printf(tostring(ship2.lives), VIRTUAL_WIDTH - 90, VIRTUAL_HEIGHT - INFOBAR_HEIGHT - 4, 50, 'right')
        -- drawBoundingBox(ship1)
        -- drawBoundingBox(ship2)
        
    elseif gameState == 'win' then
        --display winning screen
        love.graphics.setFont(FONT_SMALL)   
        love.graphics.printf( "PRESS  ENTER  FOR  MAIN  MENU", 0, VIRTUAL_HEIGHT - 65, VIRTUAL_WIDTH , 'center')
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(FONT_LARGE)   
        if ship1.lives > ship2.lives then
            love.graphics.setColor(COLOR_REDTEXT)
            love.graphics.printf( "RED WINS!", 0, VIRTUAL_HEIGHT/3, VIRTUAL_WIDTH + 15, 'center')
        elseif ship1.lives < ship2.lives then
            love.graphics.setColor(COLOR_BLUETEXT)
            love.graphics.printf("BLUE WINS", 0, VIRTUAL_HEIGHT/3, VIRTUAL_WIDTH + 15, 'center')
        else
            love.graphics.printf("TIE", 0, VIRTUAL_HEIGHT/3, VIRTUAL_WIDTH + 15, 'center')
        end
    end

    if showFPS then
        displayFPS()
    end

    push:finish()
end

function displayFPS()
    -- simple FPS display across all states
    love.graphics.setColor(0, 1, 0)
    love.graphics.setFont(FONT_SMALL)
    love.graphics.print('FPS  ' .. tostring(love.timer.getFPS()), 10, 10)
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
    ship1.exploding = false
    ship2.exploding = false
    ship1.explodeTimer = EXPLOSION_DURATION
    ship2.explodeTimer = EXPLOSION_DURATION
    respawn(ship1)
    respawn(ship2)
end

function updateShip(ship, dt)
    if ship.exploding then
        if ship.explodeTimer <= 0 then
            ship.exploding = false
            ship.explodeTimer = EXPLOSION_DURATION
            respawn(ship)
        else
            ship.explodeTimer = ship.explodeTimer - dt
        end
    else

        rotationChangeAmount = 1500 * dt
        if math.abs(ship.dr + rotationChangeAmount) <= MAX_ROTATION_SPEED then
            if love.keyboard.isDown(ship.rotKeyR) then
                ship.dr = ship.dr + rotationChangeAmount
            elseif love.keyboard.isDown(ship.rotKeyL) then
                ship.dr = ship.dr - rotationChangeAmount
            end
        end
        
        if (not love.keyboard.isDown(ship.rotKeyR)) and (not love.keyboard.isDown(ship.rotKeyL)) then
            if ship.dr > 0 then
                ship.dr = ship.dr - rotationChangeAmount
            elseif ship.dr < 0 then
                ship.dr = ship.dr + rotationChangeAmount
            end
        end

        -- if rotation key isDown() then
        --     if abs(durrent dr + what we would add) < MAX_ROTATION_SPEED then
        --         add rotation to dr
        --     end
        -- end
        -- if both rotation keys are NOT DOWN then
        --     if dr > 0
        --         subtract from dr
        --     elseif dr < 0
        --         add a bit to dr
        

        -- if math.abs(ship.dr) >= MAX_ROTATION_SPEED then
        --     if ship.dr > 0 then
        --         ship.dr = MAX_ROTATION_SPEED
        --     else
        --         ship.dr = -MAX_ROTATION_SPEED
        --     end
        -- end

        -- if love.keyboard.isDown(ship.rotKeyR) then
        --     if (ship.dr + 400) >= MAX_ROTATION_SPEED then
        --         ship.dr = MAX_ROTATION_SPEED * dt
        --     ship.dr = ship.dr + 400 * dt
        -- elseif love.keyboard.isDown(ship.rotKeyL) then
        --     ship.dr = ship.dr - 400 * dt
        -- end

        -- if (not love.keyboard.isDown(ship.rotKeyR)) and (not love.keyboard.isDown(ship.rotKeyL)) then
        --     if ship.dr > 0 then
        --         ship.dr = ship.dr - 1200 * dt
        --     elseif ship.dr < 0 then
        --         ship.dr = ship.dr + 1200 * dt
        --     end
        -- end

        if love.keyboard.isDown(ship.thrustKey) then
            ship.thrust = true
            ship.dx = ship.dx + math.sin(ship.r) * 200 * dt
            ship.dy = ship.dy - math.cos(ship.r) * 200 * dt
        else
            ship.thrust = false
        end
        
        if love.keyboard.isDown(ship.fireKey) and ship.lastBullet > 0.2 then --cooldown fire rate
            bulletArray[table.getn(bulletArray) + 1] = Bullet:create(ship, table.getn(bulletArray))
            -- Bullet:testupdate()
            ship.lastBullet = 0
            sounds['shot1']:play()
        end

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

        ship.x = ship.x + ship.dx * dt
        ship.y = ship.y + ship.dy * dt
        ship.r = ship.r + math.rad(ship.dr) * dt
    end
    ship.lastBullet = ship.lastBullet + dt
end

function respawn(ship)
    ship.lives = ship.lives - 1
    ship.x = ship.spawnX
    ship.y = ship.spawnY
    updateBoundingBox(ship)
    ship.dx = 0
    ship.dy = 0
    ship.r = math.rad(ship.spawnR)
    ship.dr = 0
    ship.lastBullet = 0
end

function explode(ship)
    ship.exploding = true
    ship.explodeTimer = EXPLOSION_DURATION
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
        sounds['hit']:play()
        explode(ship2)
        -- respawn(ship2)
        
    end
    if collides(bullet, ship1) and bullet.source == ship2 then
        bullet.disabled = true
        sounds['hit']:play()
        explode(ship1)
        -- respawn(ship1)
    end
end

function drawBullet(bullet)
    if bullet.source == ship1 then
        love.graphics.setColor(1, 0.5, 0.5)
    else
        love.graphics.setColor(0.5, 0.5, 1)
    end

    love.graphics.draw(bullet.texture, bullet.x, bullet.y, bullet.r, 2, 2)
    -- love.graphics.rectangle("fill", bullet.x - (bullet.sizeX / 2), bullet.y - (bullet.sizeY / 2), bullet.sizeX, bullet.sizeY)
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
