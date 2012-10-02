local anim8 = require 'vendor/anim8'
local sound = require 'vendor/TEsound'
local gamestate = require 'vendor/gamestate'

local Airplane = {}
Airplane.__index = Airplane

local AirplaneSprite = love.graphics.newImage('images/airplane.png')
local g = anim8.newGrid(168, 24, AirplaneSprite:getWidth(), AirplaneSprite:getHeight())

function Airplane.new(node, collider)
    local airplane = {}
    setmetatable(airplane, Airplane)

    airplane.node = node
    airplane.speed = 100
    airplane.noiseRadius = 500
    
    airplane.airplane = anim8.newAnimation('loop', g('1,1-2'), 0.5)

    return airplane
end

function Airplane:enter(dt)
    self.map = gamestate.currentState().map
    self.engineNoise = sound.startSfx( 'click', nil, self.node.x, self.node.y, self.noiseRadius )
end

function Airplane:leave()
    sound.stopSfx( self.engineNoise )
end

function Airplane:update(dt)
    self.airplane:update(dt)
    
    self.node.x = self.node.x - dt * self.speed
    if self.node.x < -self.noiseRadius then
        self.node.x = self.map.width * self.map.tilewidth + self.noiseRadius
    end
    self.engineNoise.x = self.node.x
end

function Airplane:draw()
    self.airplane:draw( AirplaneSprite, self.node.x, self.node.y )
end

return Airplane

