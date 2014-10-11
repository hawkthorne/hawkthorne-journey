local Gamestate = require 'vendor/gamestate'
local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local window = require 'window'
local fonts = require 'fonts'
local character = require 'character'

local Cornelius = {}
Cornelius.__index = Cornelius

local image = love.graphics.newImage('images/cornelius_head_2.png')
local g = anim8.newGrid(148, 195, image:getWidth(), image:getHeight())

function Cornelius.new(node, collider)
  local cornelius = {}
  setmetatable(cornelius, Cornelius)
  cornelius.node = node
  cornelius.position = { x = node.x, y = node.y }
  cornelius.offset   = { x = 30,     y = 20 }
  cornelius.width = node.width
  cornelius.height = node.height
  cornelius.character = character.current()

  cornelius.collider = collider
  cornelius.collider:setActive()
  cornelius.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  cornelius.bb.node = cornelius
  cornelius.hittable = true

  cornelius.animations = {
    talking = anim8.newAnimation('once', g('2,1', '3,1', '2,1', '3,1', '2,1', '1,1'), 0.2 ),
    idle = anim8.newAnimation('loop', g('1,1'), 1)
  }
  cornelius.state = 'idle'
  cornelius.y_center = cornelius.position.y
  cornelius.y_bob = 0

  cornelius.score = 0

  return cornelius
end

function Cornelius:collide(node, dt, mtv_x, mtv_y)
  if node and (node.isProjectile and node.name=='baseball') and node.thrown then
    -- above
    if self.position.x < node.position.x and
       self.position.x + self.width > node.position.x + node.width and
       self.position.y > node.position.y then
         node:rebound( false, true )
    elseif -- below
       self.position.x < node.position.x and
       self.position.x + self.width > node.position.x + node.width and
       self.position.y < node.position.y then
         node:rebound( false, true )
    else -- sides
      node:rebound( true, false )
    end
    --prevent multiple messages
    if self.hittable then
      self.score = self.score + 1000
      self.state = 'talking'
      sound.playSfx( 'cornelius_thats_my_boy' )
      Timer.add( .8, function()
        self.animations.talking:gotoFrame(1)
        self.state = 'idle'
      end)
    end
    self.hittable = false
    Timer.add( 1, function()
      self.hittable = true
    end)
  end
end

function Cornelius:update(dt)
  self.y_bob = (math.cos(((love.timer.getTime() - dt) / (4 / 2) + 1) * math.pi) + 1) * 10
  self.position.y = self.y_center + self.y_bob
  self:animation():update(dt)
  self:moveBoundingBox()
  if self.score >= 4000 and self.character.name == 'pierce' and self.character.costume == 'base' then
    self.character.costume = 'happy'
  end
end

function Cornelius:moveBoundingBox()
  self.bb:moveTo(self.position.x + self.width / 2,
           self.position.y + (self.height / 2) + 2)
end

function Cornelius:animation()
  return self.animations[self.state]
end

function Cornelius:draw()
  self:animation():draw( image, self.position.x - self.offset.x, self.position.y - self.offset.y )
  fonts.set( 'big' )
  love.graphics.print( self.score, window.width - 40, window.height - 40, 0, 0.5 )
  fonts.revert()
end

return Cornelius
