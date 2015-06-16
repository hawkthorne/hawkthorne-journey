local anim8 = require 'vendor/anim8'
local game = require 'game'
local collision  = require 'hawk/collision'
local utils = require 'utils'
local Timer = require 'vendor/timer'
local window = require 'window'
local Player = require 'player'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'

local Projectile = {}
Projectile.__index = Projectile
Projectile.isProjectile = true

--node requires:
-- an x and y coordinate,
-- a width and height,
-- properties.sheet
-- properties.defaultAnimation
function Projectile.new(node, collider)
  local proj = {}
  setmetatable(proj, Projectile)

  local name = node.name

  proj.type = 'projectile'
  proj.name = name
  proj.props = utils.require( 'nodes/projectiles/' .. name )
  proj.directory = node.directory

  -- projectile images are stored in weapons, need to specify here
  local dir = node.directory or "weapons/"
  -- Checking properties for when projectile is spawned in tiled
  if node.properties then
    dir = node.properties.directory or dir
    proj.defaultDirection = node.properties.direction or "right"
  end
  
  proj.sheet = love.graphics.newImage('images/'..dir..name..'.png')
  proj.foreground = proj.props.foreground

  proj.collider = collider
  -- use properties height to give proper size
  -- increase size by one to allow for breakable block collisions
  proj.bb = collider:addRectangle(node.x, node.y, proj.props.width + 1, proj.props.height + 1 )
  proj.bb.node = proj
  proj.start_x = node.x
  proj.start_y = node.y

  proj.explosive = false or proj.props.explosive
  proj.explodeTime = proj.props.explodeTime or 0

  local animations = proj.props.animations
  local g = anim8.newGrid( proj.props.frameWidth,
                          proj.props.frameHeight,
                          proj.sheet:getWidth(),
                          proj.sheet:getHeight() )
  
  proj.defaultAnimation = anim8.newAnimation(
                          animations.default[1],
                          g(unpack(animations.default[2])),
                          animations.default[3])
  proj.thrownAnimation = anim8.newAnimation(
                          animations.thrown[1],
                          g(unpack(animations.thrown[2])),
                          animations.thrown[3])
  proj.finishAnimation = anim8.newAnimation(
                          animations.finish[1],
                          g(unpack(animations.finish[2])),
                          animations.finish[3])
  if proj.explosive then
    proj.explodeAnimation = anim8.newAnimation(
                          animations.explode[1],
                          g(unpack(animations.explode[2])),
                          animations.explode[3])
  end


  proj.animation = proj.defaultAnimation
  proj.position = { x = node.x, y = node.y }
  proj.velocity = { x = proj.props.velocity.x,
                    y = proj.props.velocity.y }
  proj.bounceFactor = proj.props.bounceFactor or 0
  proj.friction = proj.props.friction or 0.7
  proj.velocityMax = proj.props.velocityMax or 400
  proj.throwVelocity = {x = proj.props.throwVelocityX or 500,
                        y = proj.props.throwVelocityY or -800,}
  proj.dropVelocity = {x = proj.props.dropVelocityX or 50}
  proj.horizontalLimit = proj.props.horizontalLimit or 2000

  proj.thrown = proj.props.thrown
  proj.holder = nil
  proj.handle_x = proj.props.handle_x or 0
  proj.handle_y = proj.props.handle_y or 0
  proj.lift = proj.props.lift or 0
  proj.width = proj.props.width
  proj.height = proj.props.height
  proj.offset = proj.props.offset or {x=0, y=0}
  proj.angle = 0
  proj.complete = false --updated by finish()
  proj.damage = proj.props.damage or 0
  proj.knockback = proj.props.knockback or 250
  -- Damage that does not affect all enemies ie. stab, fire
  -- Don't forget to pass this into hurt functions in the props file
  proj.special_damage = proj.props.special_damage or {}
  proj.solid = proj.props.solid
  proj.dropping = false
  proj.dropped = (node.properties and node.properties.dropped) or false

  proj.playerCanPickUp = proj.props.playerCanPickUp
  proj.enemyCanPickUp = proj.props.enemyCanPickUp
  proj.canPlayerStore = proj.props.canPlayerStore
  proj.usedAsAmmo = proj.props.usedAsAmmo

  if proj.props.new then
    proj.props.new(proj)
  end
  
  return proj
end

function Projectile:die()
  self.dead = true
  self.complete = true
  if self.holder then self.holder.currently_held = nil end
  self.holder = nil
  self.collider:remove(self.bb)
  if self.containerLevel then
    self.containerLevel:removeNode(self)
  end
  self.bb = nil
end

function Projectile:draw()
  if self.dead then return end
  local scaley = 1
  local angle = self.angle
  if self.velocity.x < 0 or self.defaultDirection == "left" then
    scaley = -1
    angle = angle - math.pi
  end
  self.animation:draw(self.sheet, math.floor(self.position.x), self.position.y, angle, 1, scaley)
end

function Projectile:update(dt, player, map)
  if self.dead then return end
  
  if math.abs(self.start_x - self.position.x) > self.horizontalLimit then
    self:die()
  end

  if self.holder and self.holder.currently_held == self then
    local holder = self.holder
    if holder == player then
      self.position.x = math.floor(holder.position.x) - holder.character.bbox.x + holder.width/2 + holder.offset_hand_left[1]
      self.position.y = math.floor(holder.position.y) - holder.character.bbox.y - self.height + holder.offset_hand_left[2]
    else -- used only for manicorns
      local scalex = 1
      if self.holder.direction and self.holder.direction == 'left' then
        scalex = -1
      end
      self.position.x = math.floor(holder.position.x) + holder.width/2 - self.width/2 + holder.offset_hand_right[1] + scalex*self.handle_x
      self.position.y = math.floor(holder.position.y) -self.height/2 + holder.offset_hand_right[2] + self.handle_y
    end
  end
  
  local nx, ny = collision.move(map, self, self.position.x + self.offset.x,
                                self.position.y + self.offset.y,
                                self.width, self.height, 
                                self.velocity.x * dt, self.velocity.y * dt)
  if self.thrown then
    --update speed
    if self.velocity.x < 0 then
      self.velocity.x = math.min(self.velocity.x + self.friction * dt, 0)
    else
      self.velocity.x = math.max(self.velocity.x - self.friction * dt, 0)
    end
    self.velocity.y = self.velocity.y + (game.gravity-self.lift)*dt

    if self.velocity.y > self.velocityMax then
      self.velocity.y = self.velocityMax
    end
    self.velocity.x = Projectile.clip(self.velocity.x,self.velocityMax)
    
    self.position.x = nx - self.offset.x
    self.position.y = ny - self.offset.y
  end

  if self.dropping then
    self.position.x = nx
    self.position.y = ny
    -- X velocity won't need to change
    self.velocity.y = self.velocity.y + game.gravity*dt
  end

  -- Item has finished dropping in the level
  if not self.dropping and self.dropped and not self.saved then
    self.containerLevel:saveAddedNode(self)
    self.saved = true
  end

  if self.props.update then
    self.props.update(dt, self)
  end

  self:moveBoundingBox()
  self.animation:update(dt)
end

function Projectile:keypressed( button, player)
  if self.player or self.thrown or self.playerCanPickUp or not self.canPlayerStore then return end

  if button == 'INTERACT' then
    --the following invokes the constructor of the specific item's class
    local Item = require 'items/item'
    local itemNode = utils.require ('items/weapons/'..self.name)
    local item = Item.new(itemNode, self.quantity)
    local callback = function()
      if self.bb then
        self.collider:remove(self.bb)
      end
      self.containerLevel:saveRemovedNode(self)
      self.containerLevel:removeNode(self)
      self.dead = true
      if not player.currently_held then
        item:select(player)
      end
    end
    player.inventory:addItem(item, true, callback)
  end
end

function Projectile.clip(value,bound)
  bound = math.abs(bound)
  if value > bound then
    return bound
  elseif value < -bound then
    return -bound
  else
    return value
  end
end

function Projectile:moveBoundingBox()
  if self.dead then return end
  local scalex = 1
  if self.velocity.x < 0 or self.defaultDirection == "left" then
    scalex = -1
  end
  self.bb:moveTo(self.position.x + scalex*self.offset.x + scalex*self.width / 2,
                 self.position.y + self.offset.y + self.height / 2 )
end

function Projectile:collide(node, dt, mtv_x, mtv_y)
  if not node or self.dead then return end

  if (node.isPlayer and self.playerCanPickUp and not self.holder) or
     (node.isEnemy and self.enemyCanPickUp and not self.holder) then
    node:registerHoldable(self)
  end

  if self.props.collide then
    if self.dropped then return end
    self.props.collide(node, dt, mtv_x, mtv_y,self)
  end
end

function Projectile:collide_end(node, dt)
  if not node or self.dead then return end

  if (node.isEnemy and self.enemyCanPickUp) or
     (node.isPlayer and self.playerCanPickUp) then
    node:cancelHoldable(self)
  end
  if self.props.collide_end then
    self.props.collide_end(node, dt, self)
  end
  if self.explosive and node.isEnemy then
    -- Projectiles use velocity to determine direction, this ensures proper direction
    -- is use, -1 is small enough to be a negligable velocity
    self.velocity.x = self.velocity.x < 0 and -1 or 0
    self.animation = self.explodeAnimation

    if self.props.explode_sound then
      sound.playSfx( self.props.explode_sound )
    end
    Timer.add(self.explodeTime, function () 
      self:die()
    end)
  end
end

function Projectile:leave()
  if self.props.leave then
    self.props.leave(self)
  end
end

--@returns the object that was picked up
-- or nil if nothing was
function Projectile:pickup(node)
  if not node or node.holder or self.dead then return end

  if node.isPlayer and not self.playerCanPickUp then return end
  if node.isEnemy and not self.enemyCanPickUp then return end

  self.complete = false
  self.animation = self.defaultAnimation

  self.holder = node
  self.thrown = false
  self.velocity.y = 0
  self.velocity.x = 0
  return self
end

function Projectile:floor_pushback(tile)
  if self.dead then return end
  -- Tile id 104-129 corresponds to breakable blocks
  if tile and (tile.id >= 104 and tile.id <= 129) then return end
  if self.solid and self.thrown then self:die() end

  -- Pushback code for a dropped item
  if self.dropped then
    self.dropping = false
    self.velocity.y = 0
    return
  end

  if not self.thrown then return end
  if self.velocity.y<25 then
    self.thrown = false
    self.velocity.y = 0
    self:finish()
  else
    self.velocity.y = -self.velocity.y * self.bounceFactor
    self.velocity.x = self.velocity.x * self.friction
  end
  
  if self.props.floor_collide then self.props.floor_collide(self) end
end

function Projectile:wall_pushback(tile)
  if self.dead then return end
  -- Tile id 104-129 corresponds to a breakable blocks
  if tile and (tile.id >= 104 and tile.id <= 129) then return end
  if self.solid then self:die() end
  
  self.velocity.y = self.velocity.y * self.friction
  self.velocity.x = -self.velocity.x * self.bounceFactor
end

--used only for objects when hitting cornelius
function Projectile:rebound( x_change, y_change )
  if self.dead then return end

  if not self.rebounded then
    if x_change then
      self.velocity.x = -( self.velocity.x / 2 )
    end
    if y_change then
      self.velocity.y = -self.velocity.y
    end
    self.rebounded = true
  end
end
function Projectile:throw(thrower)
  if self.dead then return end

  self.animation = self.thrownAnimation
  thrower.currently_held = nil
  self.holder = nil
  self.thrown = true
  
  if self.props.throw_sound then
      sound.playSfx( self.props.throw_sound )
  end
  local direction = thrower.direction or thrower.character.direction
  if direction == "left" then
    self.velocity.x = -self.throwVelocity.x + thrower.velocity.x
  else
    self.velocity.x = self.throwVelocity.x + thrower.velocity.x
  end
  self.velocity.y = self.throwVelocity.y
end

function Projectile:throw_vertical(thrower)
  if self.dead then return end

  self.animation = self.thrownAnimation
  thrower.currently_held = nil
  self.holder = nil
  self.thrown = true

  self.velocity.x = thrower.velocity.x
  self.velocity.y = self.throwVelocity.y
end

--launch() executes the following in order(if they exist)
--1) charge()
--2) throw()
--3) finish()
function Projectile:launch(thrower)
  if self.dead then return end

  self:charge(thrower)
  Timer.add(thrower.chargeUpTime or 0, function()
    if self.holder == thrower then
      self:throw(thrower)
    --otherwise it would have already been destroyed
    end
  end)
end

function Projectile:charge(thrower)
  if self.dead then return end

  self.animation = self.defaultAnimation
  if self.props.charge then
    self.props.charge(thrower,self)
  end
end

function Projectile:finish(thrower)
  if self.dead then return end

  self.complete = true
  self.animation = self.finishAnimation
  if self.props.finish then
    self.props.finish(thrower,self)
  end
end

function Projectile:drop(thrower)
  if self.dead then return end

  self.animation = self.defaultAnimation
  thrower.currently_held = nil
  self.holder = nil
  if thrower.footprint then
    self:floorspace_drop(thrower)
    return
  end
  self.dropping = true
  self.dropped = true
end

-- handle projectile being dropped in a floorspace
function Projectile:floorspace_drop(player)
  self.position.y = player.footprint.y - self.height

  self.containerLevel:saveAddedNode(self)
end

return Projectile
