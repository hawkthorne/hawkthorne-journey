local Footprint = {}
Footprint.__index = Footprint
Footprint.isFootprint = true

---
-- Create a new owner
-- @param collider
-- @return owner
function Footprint.new(collider,owner)

    local footprint = {}

    setmetatable(footprint, Footprint)

    footprint.collider = collider
    footprint.width = 4
    footprint.height = 4
    footprint.y = owner.position.y + owner.height
    footprint.x = owner.position.x+owner.width/2-footprint.width/2
    footprint.bb = collider:addRectangle(owner.position.x+owner.width/2-footprint.width/2,footprint.y,
                                         footprint.width,footprint.height)
    footprint.bb.node = footprint
    footprint.owner = owner

    return footprint
end

function Footprint:update()
    local owner = self.owner

    if owner.outofbounds and owner.onFloorspace then
        self.x = self.last_x
        self.y = self.last_y
        self:moveOwnerToFootprint()
    elseif not owner.jumping then
        self.y = self.owner.position.y + self.owner.height
    end

    self.x = owner.position.x+owner.width/2
    self.bb:moveTo(self.x,self.y)
end

function Footprint:reset()
    self.y = self.owner.position.y + self.owner.height
end

function Footprint:moveOwnerToFootprint()
    local owner = self.owner
    owner.position.x  = self.x - owner.width/2
    if not owner.jumping then
        owner.position.y  = self.y - owner.height
    end 
end

return Footprint
    