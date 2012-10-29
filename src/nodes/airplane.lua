local anim8 = require 'vendor/anim8'
local sound = require 'vendor/TEsound'
local gamestate = require 'vendor/gamestate'
local Platform = require 'nodes/platform'

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

    airplane.platform_node = deepcopy(node)
    airplane.platform_node.width = 15
    airplane.platform_node.height = 3
    airplane.platform = Platform.new( airplane.platform_node, collider )

    airplane.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    airplane.bb.node = airplane
    collider:setPassive(airplane.bb)

    return airplane
end

function Airplane:enter(dt)
    self.map = gamestate.currentState().map
    self.engineNoise = sound.startSfx( 'click', nil, self.node.x, self.node.y, self.noiseRadius )
end

function Airplane:collide(player, dt, mtv_x, mtv_y)
    if not player.currentplatform then
        player.currentplatform = self
    end
    if mtv_x == 0 and mtv_y < 0 then
        self.ontop = true
    else
        self.ontop = false
    end
end

function Airplane:collide_end(player,dt)
    if player.currentplatform == self then
        player.currentplatform = nil
    end
end

function Airplane:leave()
    sound.stopSfx( self.engineNoise )
end

function Airplane:update(dt, player)
    self.airplane:update(dt)
    self.platform:update(dt)
    
    self.node.x = self.node.x - dt * self.speed
    
    -- move the player along with the bounding box
    if player.currentplatform == self and self.ontop then
        player.position.x = player.position.x - dt * self.speed
        player:moveBoundingBox()
    end
    
    self.platform.bb:moveTo( self.node.x + 20,
                             self.node.y + 3)
    self.bb:moveTo( self.node.x + self.node.width / 2,
                 self.node.y + (self.node.height / 2) + 1 )
                 
    if self.node.x < -self.noiseRadius then
        self.node.x = self.map.width * self.map.tilewidth + self.noiseRadius
    end
    self.engineNoise.x = self.node.x
end

function Airplane:draw()
    self.airplane:draw( AirplaneSprite, self.node.x, self.node.y )
end

function Airplane:keypressed( button, player )
    self.platform:keypressed( button, player )
end

function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

return Airplane

