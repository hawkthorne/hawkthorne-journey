local Cow = {}

Cow.__index = Cow

local image = love.graphics.newImage('images/cow.png')
image:setFilter('nearest', 'nearest')

function Cow.new(node, collider)
    local cow = {}
    setmetatable(cow, Cow)

    cow.x = node.x
    cow.y = node.y
    
    return cow
end

function Cow:update(dt)
end

function Cow:draw()
    love.graphics.draw(image, self.x, self.y)
end

return Cow


