local Gamestate = require 'vendor/gamestate'

local Painting = {}
Painting.__index = Painting

local image = love.graphics.newImage('images/painting.png')
local crooked = love.graphics.newQuad(78, 0, 78, 66, image:getWidth(),
                                      image:getHeight())
local fixed = love.graphics.newQuad(0, 0, 78, 66, image:getWidth(),
                                    image:getHeight())

function Painting.new(node, collider)
    local art = {}
    setmetatable(art, Painting)
    art.x = node.x
    art.y = node.y
    art.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    art.bb.node = art
    art.player_touched = false
    art.fixed = false
    collider:setPassive(art.bb)
    return art
end

function Painting:draw()
    if self.fixed then
        love.graphics.drawq(image, fixed, self.x, self.y)
    else
        love.graphics.drawq(image, crooked, self.x, self.y)
    end
end

function Painting:keypressed(key, player)
    if key == 'rshift' or key == 'lshift' then
        player.painting_fixed = true
        self.fixed = true
    end
end

return Painting


