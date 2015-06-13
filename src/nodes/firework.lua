local anim8 = require 'vendor/anim8'
local app = require 'app'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'

local Firework = {}
Firework.__index = Firework
Firework.isFirework = true

local image = love.graphics.newImage('images/firework.png')
image:setFilter('nearest', 'nearest')

local g = anim8.newGrid(172, 340, image:getWidth(), image:getHeight())

local states = {
  explode = anim8.newAnimation('once', g('1-13,1'), 0.15)
}

---
-- Creates a new Firework object
-- @param parent the parent node that the firework are added to
function Firework.new( node )
  local firework = {}
  setmetatable(firework, Firework)

  firework.state = 'explode'

  firework.x = node.x
  firework.y = node.y

  Timer.add(0.15, function()
    sound.playSfx('firework')
  end)

  return firework
end

function Firework:update(dt)
  states[self.state]:update(dt)
end

function Firework:draw()
  states[self.state]:draw(image, self.x, self.y)
end

return Firework
