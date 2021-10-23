BoundingBox = {}

function BoundingBox:create(object)
    local b = {}
    setmetatable(b,BoundingBox)

    b.x = (object.x - object.size / 2) + object.boundOffset
    b.y = (object.y - object.size / 2) + object.boundOffset

    b.size = object.size - (2 * object.boundOffset)

    return b
end
