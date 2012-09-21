local Helper = {}

---
-- Given an object that conforms to the node standard, this will reposition the
-- Bounding Box to the object
-- @param object
-- @return nil
function Helper.moveBoundingBox(object)
    object.bb:moveTo(object.position.x + object.width / 2,
                     object.position.y + (object.height / 2) + 2)
end

return Helper