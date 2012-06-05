local Cow = {}

Cow.__index = Cow

function Cow.create(x, y, image)
    local cow = {}
    setmetatable(cow, Cow)

    cow.image = image
    cow.image:setFilter('nearest', 'nearest')
    cow.x = x
    cow.y = y
    
    return cow
end

function Cow:update(dt)
end

function Cow:draw()
    love.graphics.draw(self.image, self.x, self.y)
end

return Cow


