Bullet = {}

function Bullet:create(ship, index)
    local b = {}
    setmetatable(b,Bullet)

    b.source = ship
    b.index = index
    b.texture = love.graphics.newImage("assets/textures/bullet.png")
    b.x = ship.x
    b.y = ship.y - math.cos(ship.r)
    b.r = ship.r
    b.sizeX = 3
    b.sizeY = 3
    b.boundOffset = 0
    b.disabled = false

    speed = 800
    b.dx = math.sin(ship.r) * speed
    b.dy = -math.cos(ship.r) * speed
    b.boundingBox = BoundingBox:create(b)
    
    return b
end

