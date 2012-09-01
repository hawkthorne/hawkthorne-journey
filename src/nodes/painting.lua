local Gamestate = require 'vendor/gamestate'
local Prompt = require 'prompt'
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
		if self.fixed then
        self.prompt = Prompt.new(120, 55, "Unstraighten masterpiece?", function(result)
		if result then
			player.painting_fixed = false
            self.fixed = false
		end
		end)
		elseif not self.fixed then
			self.prompt = Prompt.new(120, 55, "Straighten masterpiece?", function(result)
			player.painting_fixed = result
            self.fixed = result
		end)
        end
		player.freeze = false
    end

    if self.prompt then
        self.prompt:keypressed(key)
    end
end

return Painting


