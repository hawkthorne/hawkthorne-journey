local Gamestate = require 'vendor/gamestate'
local Prompt = require 'prompt'
local Alarm = {}
Alarm.__index = Alarm

local image = love.graphics.newImage('images/firealarm.png')
local not_broken_img = love.graphics.newQuad( 0, 0, 24,48, image:getWidth(), image:getHeight() )
local broken_img = love.graphics.newQuad( 24, 0, 24,48, image:getWidth(), image:getHeight() )

local broken = false

function Alarm.new(node, collider)
    local art = {}
    setmetatable(art, Alarm)
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

function Alarm:update(dt)
    if self.prompt then self.prompt:update(dt) end
end

function Alarm:draw()
    if self.broken then
        love.graphics.drawq(image, broken_img, self.x, self.y)
    else
        love.graphics.drawq(image, not_broken_img, self.x, self.y)
    end

    if self.prompt then
        self.prompt:draw(self.x + 78, self.y - 35)
    end
end

function Alarm:keypressed(key, player)
    if (key == 'rshift' or key == 'lshift')
        and (self.prompt == nil or self.prompt.state ~= 'closed')
        and (not self.broken) then
        player.freeze = true
        self.prompt = Prompt.new(120, 55, "Pull the fire alarm?", function(result)
            self.broken = result
            player.freeze = false
        end)
    end

    if self.prompt then
        self.prompt:keypressed(key)
    end
end

return Alarm


