Bullet = {}

function Bullet:create(ship)
    local tmpBullet = {}
    setmetatable(tmpBullet,Bullet)

    tmpBullet.source = ship

    tmpBullet.x = ship.x
    tmpBullet.y = ship.y - math.cos(ship.r)

    speed = 800
    tmpBullet.dx = math.sin(ship.r) * speed
    tmpBullet.dy = -math.cos(ship.r) * speed
    
    return tmpBullet
end


