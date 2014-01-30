local Gamestate = require 'vendor/gamestate'
local Prompt = require 'prompt'
local sound = require 'vendor/TEsound'
local Alarm = {}
Alarm.__index = Alarm
-- Nodes with 'isInteractive' are nodes which the player can interact with, but not pick up in any way
Alarm.isInteractive = true

local image = love.graphics.newImage('images/sprites/greendale/firealarm.png')
local not_broken_img = love.graphics.newQuad( 0, 0, 24,72, image:getWidth(), image:getHeight() )
local broken_img = love.graphics.newQuad( 24, 0, 24,72, image:getWidth(), image:getHeight() )
local psPaintImage = love.graphics.newImage('images/sprites/greendale/ps_paint.png')
local psPaint = love.graphics.newParticleSystem(psPaintImage, 100)

local broken = false
local activated = false

function Alarm.new(node, collider)
    initPaint()
    local alarm = {}
    setmetatable(alarm, Alarm)
    alarm.x = node.x
    alarm.y = node.y
    alarm.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    alarm.bb.node = alarm
    alarm.player_touched = false
    alarm.fixed = false
    alarm.prompt = nil
    collider:setPassive(alarm.bb)
    return alarm
end
    
function Alarm:update(dt)
    psPaint:update(dt)
end

function Alarm:draw()
    if self.broken then
        love.graphics.draw(image, broken_img, self.x, self.y)
    else
        love.graphics.draw(image, not_broken_img, self.x, self.y)
    end

    love.graphics.draw(psPaint, self.x + 12, 40);
end

function Alarm:leave()
    psPaint:stop()
    sound.stopSfx()
end

function Alarm:keypressed( button, player )
  if button == 'INTERACT' and self.prompt == nil then
    if not self.activated then
      player.freeze = true
      self.prompt = Prompt.new("Pull the fire alarm?", function(result)
        self.activated = result == 'Yes'
        if (result == 'Yes') then
          sound.playSfx( "alarmswitch" )
          if (math.random() > 0.5) then
            player.painted = true
            sound.playSfx( "spray" )
            psPaint:start()
          else
            self.broken = true
          end
        end
        player.freeze = false
        self.prompt = nil
      end)
    elseif not self.broken then
      sound.playSfx( "alarmswitch" )
    end
  end
end

function initPaint()
  psPaint:setBufferSize(200)
  psPaint:setColors(255,138,20,255,255,138,20,128)
  psPaint:setDirection(1.5)
  psPaint:setEmissionRate(180)
  psPaint:setLinearAcceleration(20,20)
  psPaint:setEmitterLifetime(20)
  psPaint:setParticleLifetime(1.0,1.0)
  psPaint:setRadialAcceleration(100,100)
  psPaint:setRotation(0,0)
  psPaint:setSizes(0.3,0.4,0.5)
  psPaint:setSpeed(100,200)
  psPaint:setSpin(0,0)
  psPaint:setSpread(1.4)
  psPaint:setTangentialAcceleration(69,0)
  psPaint:stop()
end

return Alarm


