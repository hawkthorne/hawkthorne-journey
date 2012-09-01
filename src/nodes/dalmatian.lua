local Gamestate = require 'vendor/gamestate'
local Prompt = require 'prompt'
local Painting = {}
Painting.__index = Painting

local image = love.graphics.newImage('images/dalmatian.png')
local crooked = love.graphics.newQuad(0, 0, 24, 42, image:getWidth(),
                                      image:getHeight())
local fixed = love.graphics.newQuad(24, 0, 24, 42, image:getWidth(),
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
    art.prompt = nil
    collider:setPassive(art.bb)
    return art
end

function Painting:update(dt)
    if self.prompt then self.prompt:update(dt) end
end

function Painting:draw()
    if self.fixed then
        love.graphics.drawq(image, fixed, self.x, self.y)
    else
        love.graphics.drawq(image, crooked, self.x, self.y)
    end

    if self.prompt then
        self.prompt:draw(self.x + 78, self.y - 35)
    end
end

function Painting:keypressed(key, player)
    if (key == 'rshift' or key == 'lshift')
        and (self.prompt == nil or self.prompt.state ~= 'closed') then
        player.freeze = true
        self.prompt = Prompt.new(120, 55, "Move dalmatian statue?", function(result)
            if not self.fixed then
				player.painting_fixed = result
				self.fixed = result
			elseif self.fixed and result then
				player.painting_fixed = false
				self.fixed = false
			end
			player.freeze = false
        end)
    end

    if self.prompt then
        self.prompt:keypressed(key)
    end
end

return Painting


