local Cow = {}

Cow.__index = Cow

function Cow.create(x, y)
    local cow = {}
    setmetatable(cow, Cow)

    cow.image = love.graphics.newImage('images/cow.png')
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


