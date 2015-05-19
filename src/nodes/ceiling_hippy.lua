local anim8 = require 'vendor/anim8'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local enemy = require 'nodes/enemy'

local CeilingHippie = {}
CeilingHippie.__index = CeilingHippie

local open_ceiling = love.graphics.newImage('images/sprites/greendale/open_ceiling.png')
local broken_tiles = love.graphics.newImage('images/sprites/greendale/broken_tiles.png')

function CeilingHippie.new( node, collider )
  local ceilinghippie = {}
  setmetatable(ceilinghippie, CeilingHippie)

  ceilinghippie.node = node
  ceilinghippie.collider = collider
  ceilinghippie.width = 48
  ceilinghippie.height = 48
  ceilinghippie.proximity = tonumber(node.properties.proximity) or 30
  ceilinghippie.drop_delay = tonumber(node.properties.delay) or 0.2
  ceilinghippie.dropped = false
  ceilinghippie.dropping = false

  -- This prevents every hippie from dropping
  local p = tonumber(node.properties.prob) or 0.6
  ceilinghippie.can_drop = math.random() < p 
  
  return ceilinghippie
end

function CeilingHippie:enter()
  self.floor = self.containerLevel.map.objectgroups.block.objects[1].y - self.height
end

function CeilingHippie:leave()
  self.can_drop = false
end

function CeilingHippie:update(dt, player)
  if not self.dropped then
    local player_x = player.position.x - player.character.bbox.x

    local playerdistance = math.abs(player_x - self.node.x) - self.width/2 - player.character.bbox.width/2
    if self.can_drop and playerdistance <= self.proximity then
      self.dropping = true
      Timer.add(self.drop_delay, function()
        -- Don't add hippy if we left the level
        if not self.can_drop then return end

        sound.playSfx( 'hippy_enter' )

        local level = self.containerLevel
        local node = enemy.new( self.node, self.collider, 'hippy' )
        level:addNode(node)
        self.hippie = node

        self.hippie.position = {x=self.node.x + 12, y=self.node.y}
        self.hippie.velocity.y = 300
      end)
      
      self.dropped = true
    end
  end
end

function CeilingHippie:draw()
  if not self.dropping then return end
  
  love.graphics.draw( open_ceiling, self.node.x - 24, self.node.y )

  if not self.dropped then return end
  
  love.graphics.draw( broken_tiles, self.node.x - 24, self.floor + self.node.height * 2 )
end

return CeilingHippie
