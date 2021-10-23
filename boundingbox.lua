BoundingBox = {}

function BoundingBox:create(object)
    local b = {}
    setmetatable(b,BoundingBox)

    b.x = (object.x - object.sizeX / 2) + object.boundOffset
    b.y = (object.y - object.sizeY / 2) + object.boundOffset

    b.sizeX = object.sizeX - (2 * object.boundOffset)
    b.sizeY = object.sizeY - (2 * object.boundOffset)

    return b
end
