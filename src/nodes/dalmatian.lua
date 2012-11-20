local Gamestate = require 'vendor/gamestate'
local Prompt = require 'prompt'
local Timer = require 'vendor/timer'

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

function Painting:enter()
    Gamestate.currentState().doors.filecabinet.node:hide()
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

function Painting:collide(node, dt, mtv_x, mtv_y)
    if node.isPlayer then
        node.interactive_collide = true
    end
end

function Painting:collide_end(node, dt)
    if node.isPlayer then
        node.interactive_collide = false
    end
end

function Painting:keypressed( button, player)
    if button == 'A' and self.prompt == nil then
        player.freeze = true
        self.prompt = Prompt.new(120, 55, "Move dalmatian statue?", function(result)
            if result == 1 then Gamestate.currentState().doors.filecabinet.node:show() end
            player.freeze = false
            self.fixed = result == 1
            Timer.add(2, function() self.fixed = false end)
            self.prompt = nil
        end)
    end

    if self.prompt then
        self.prompt:keypressed( button )
    end
end

return Painting


