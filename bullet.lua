Bullet = {}

function Bullet:create(ship, index)
    local b = {}
    setmetatable(b,Bullet)

    b.source = ship
    b.index = index
    b.x = ship.x
    b.y = ship.y - math.cos(ship.r)
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

