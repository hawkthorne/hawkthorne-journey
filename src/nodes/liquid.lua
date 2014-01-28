-- General use 'liquid' node for things like quicksand and waterfalls
-- Set properties on the object to control

-- Required:
-- 'sprite' ( filepath ) - the path to the single image sprite for animation
--             Note: format for this sprite is 24x24 tiles, 2 rows, where the top
--             row is the top of the object and the bottom row is tiled across the remainder

-- Optional properties:
-- 'tile_height' ( integer ) - Height of the sprite tiles ( deafults to 24 )
-- 'tile_width' ( integer ) - Width of the sprite tiles ( deafults to 24 )
-- 'death' ( true / false ) - Player dies immediaetly on contact with liquid
-- 'injure' ( true / false ) - Player is injured for as long as they are touching the liquid
-- 'drown' ( true / false ) - Player dies when his head is submersed in the liquid
-- 'drag' ( true / false ) - Player is slowly dragged down by the liquid ( like quicksand )
-- 'speed' ( 0 => 1 ) - Speed at which the animation is played ( defaults to 0.2 )
-- 'mode' ( 'loop', 'once' or 'bounce' ) - Mode to play the animation at ( defaults to loop )
-- 'foreground' ( true / false ) - Render the sprites in front of the player ( defaults to true )
-- 'mask' ( true / false ) - Mask the player to the left, right and below from being rendered ( defaults to false )
-- 'uniform' ( true / false ) - Use the same animation across all horizontal tiles. False will offset each column by one animation frame ( defaults to false )
-- 'opacity' ( 0 => 1 ) - Opacity of the image, where 0 is transparent, 1 is opaque ( defaults to 1 )
-- 'fade' ( true / false ) - Fades the object from 1 at the top to 'opacity' at the bottom. ( defaults to false )

local utils = require 'utils'
local anim8 = require 'vendor/anim8'
local cheat = require 'cheat'
local window = require 'window'

local Liquid = {}
Liquid.__index = Liquid
Liquid.isLiquid = true

function Liquid.new(node, collider)
  local np = node.properties

  local liquid = {}
  setmetatable(liquid, Liquid)

  liquid.collider = collider
  liquid.width = node.width
  liquid.height = node.height

  assert(np.sprite, 'Liquid Object (' .. node.name .. ') must specify "sprite" property ( path )' )
  liquid.image = love.graphics.newImage( np.sprite )
  liquid.tile_height = np.tile_height and tonumber(np.tile_height) or 24
  liquid.tile_width = np.tile_width and tonumber(np.tile_width) or 24

  liquid.g = anim8.newGrid( liquid.tile_height, liquid.tile_width, liquid.image:getWidth(), liquid.image:getHeight())
  liquid.animation_mode = np.mode and np.mode or 'loop'
  liquid.animation_speed = np.speed and tonumber(np.speed) or .2
  liquid.animation_top_frames = '1-' .. math.floor( liquid.image:getWidth() / liquid.tile_width ) .. ',1'
  liquid.animation_bottom_frames = '1-' .. math.floor( liquid.image:getWidth() / liquid.tile_width ) .. ',2'
  liquid.animation_top = anim8.newAnimation( liquid.animation_mode, liquid.g( liquid.animation_top_frames ), liquid.animation_speed )
  liquid.animation_bottom = anim8.newAnimation( liquid.animation_mode, liquid.g( liquid.animation_bottom_frames ), liquid.animation_speed )

  liquid.position = {x=node.x, y=node.y}

  liquid.death = np.death == 'true'
  liquid.injure = np.injure == 'true'
  liquid.drown = np.drown == 'true'
  liquid.drag = np.drag == 'true'
  liquid.foreground = np.foreground ~= 'false'
  liquid.mask = np.mask == 'true'
  liquid.uniform = np.uniform == 'true'
  liquid.opacity = np.opacity and np.opacity or 1
  liquid.fade = np.fade == 'true'
  
  liquid.stencil = function()
    love.graphics.rectangle( 'fill', node.x - 100, node.y - 100, node.width + 200, 100)
    love.graphics.rectangle( 'fill', node.x, node.y, node.width, node.height )
  end

  liquid.bb = collider:addRectangle(node.x, node.y + 3, node.width, node.height - 3)
  liquid.bb.node = liquid
  collider:setPassive(liquid.bb)

  return liquid
end

function Liquid:collide(node, dt, mtv_x, mtv_y)
  if node.isEnemy then
    local enemy = node
    if enemy.props.name == "fish" then return end
    if (self.death) or (self.drown and enemy.position.y >= self.position.y) then
      enemy:die()
    end
  end

  if not node.isPlayer then return end
  local player = node

  -- mask the player outside the liquid
  if self.mask then player.stencil = self.stencil end
  
  if self.death then
    player.health = 0
    player.dead = true
    self.died = true
  end

  if self.injure then
    player:hurt(10)
  end

  if self.drown and player.position.y >= self.position.y then
    player.health = 0
    player.dead = true
  end

  if self.drag then
    player.fall_damage = 0
    player.rebounding = false
    player.liquid_drag = true

    if player.velocity.x > 20 then
      player.velocity.x = 20
    elseif player.velocity.x < -20 then
      player.velocity.x = -20
    end

    if player.velocity.y > 0 then
      player:restore_solid_ground()
      player.jumping = false
      player.velocity.y = 20 * player.jumpFactor
    end
  end
end

function Liquid:collide_end(node, dt, mtv_x, mtv_y)
  if not node.isPlayer then return end
  local player = node
  
  -- unmask
  if self.mask then player.stencil = nil end
  
  if self.drag and player.liquid_drag then
    player.liquid_drag = false
    if player.velocity.y < 0 then
      player.velocity.y = player.velocity.y - 200
    end
  end
end

function Liquid:update(dt, player)
  self.animation_top:update(dt)
  self.animation_bottom:update(dt)
  if self.died and player.position.y + player.height < self.position.y + self.height then
    player.position.y = player.position.y + 20 * dt
  end
end

function Liquid:draw()
  love.graphics.setColor( 255, 255, 255, self.fade and 255 or utils.map( self.opacity, 0, 1, 0, 255 ) )
  for i = 0, ( self.width / 24 ) - 1, 1 do
    love.graphics.draw(
      self.image,
      self.animation_top.frames[ ( ( self.animation_top.position + ( self.uniform and 0 or i ) ) % #self.animation_top.frames ) + 1 ],
      self.position.x + ( i * 24 ),
      self.position.y
    )
    for j = 1, ( self.height / 24 ) - 1, 1 do
      love.graphics.setColor(
        255, 255, 255,
        utils.map( 
            self.fade and ( 1 - ( ( 1 - self.opacity ) / ( ( self.height / 24 ) - 1 ) * j ) ) or self.opacity,
            0, 1, 0, 255
        )
      )
      love.graphics.draw(
        self.image,
        self.animation_bottom.frames[ ( ( self.animation_bottom.position + ( self.uniform and 0 or i ) ) % #self.animation_top.frames) + 1 ],
        self.position.x + ( i * 24 ),
        self.position.y + ( j * 24 )
      )
    end
  end
  love.graphics.setColor( 255, 255, 255, 255 )
end

return Liquid
