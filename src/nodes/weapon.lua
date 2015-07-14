-----------------------------------------------
-- weapon.lua
-- Represents a generic weapon a player can wield or pick up
-- I think there should be only 2 types of weapons:
---- the only action that should play once is the animation for ing your weapon
-- Created by NimbusBP1729
-----------------------------------------------
local sound = require 'vendor/TEsound'
local anim8 = require 'vendor/anim8'
local game = require 'game'
local collision  = require 'hawk/collision'
local utils = require 'utils'
local gamestate = require 'vendor/gamestate'
local camera = require 'camera'
local app = require 'app'

local Weapon = {}
Weapon.__index = Weapon
Weapon.isWeapon = true

function Weapon.new(node, collider, plyr, weaponItem)
  local weapon = {}
  setmetatable(weapon, Weapon)

  weapon.name = node.name
  weapon.type = node.type

  weapon.props = utils.require( 'nodes/weapons/' .. weapon.name )
  weapon.item = weaponItem

  -- Checks if for plyr and if plyr is a player
  weapon.player = (plyr and plyr.isPlayer) and plyr or nil

  weapon.quantity = node.properties.quantity or weapon.props.quantity or 1

  weapon.foreground = node.properties.foreground == 'true'
  weapon.position = {x = node.x, y = node.y}
  weapon.velocity={}
  weapon.velocity.x = node.properties.velocityX or 0
  weapon.velocity.y = node.properties.velocityY or 0

  --position that the hand should be placed with respect to any frame
  weapon.hand_x = weapon.props.hand_x
  weapon.hand_y = weapon.props.hand_y

  --setting up the sheet
  local colAmt = weapon.props.frameAmt
  if node.properties.sprite then
    weapon.image = love.graphics.newImage(node.properties.sprite)
  end
  weapon.sheet = love.graphics.newImage('images/weapons/'..weapon.name..'.png')
  weapon.sheetWidth = weapon.sheet:getWidth()
  weapon.sheetHeight = weapon.sheet:getHeight()
  weapon.frameWidth = weapon.sheetWidth/colAmt
  weapon.frameHeight = weapon.sheetHeight-15
  weapon.width = weapon.props.width or 10
  weapon.height = weapon.props.height or 10
  weapon.dropWidth = weapon.props.dropWidth
  weapon.dropHeight = weapon.props.dropHeight
  weapon.bbox_width = weapon.props.bbox_width
  weapon.bbox_height = weapon.props.bbox_height
  weapon.bbox_offset_x = weapon.props.bbox_offset_x
  weapon.bbox_offset_y = weapon.props.bbox_offset_y
  weapon.magical = weapon.props.magical or false

  weapon.wield_rate = weapon.props.animations.wield[3]

  local g = anim8.newGrid(weapon.frameWidth, weapon.frameHeight,
      weapon.sheetWidth, weapon.sheetHeight)
  weapon.defaultAnimation = anim8.newAnimation(
        weapon.props.animations.default[1],
        g(unpack(weapon.props.animations.default[2])),
        weapon.props.animations.default[3])
  weapon.wieldAnimation = anim8.newAnimation(
        weapon.props.animations.wield[1],
        g(unpack(weapon.props.animations.wield[2])),
        weapon.props.animations.wield[3])
  if weapon.magical then
    weapon.projectile = node.properties.projectile
    weapon.chargeUpTime = 0
    weapon.charged = false
    weapon.defaultChargedAnimation = anim8.newAnimation(
          weapon.props.animations.defaultCharged[1],
          g(unpack(weapon.props.animations.defaultCharged[2])),
          weapon.props.animations.defaultCharged[3])
    weapon.wieldChargedAnimation = anim8.newAnimation(
          weapon.props.animations.wieldCharged[1],
          g(unpack(weapon.props.animations.wieldCharged[2])),
          weapon.props.animations.wieldCharged[3])
    weapon.cameraShake = weapon.props.cameraShake or false
    weapon.camera = {
      tx = 0,
      ty = 0,
      sx = 1,
      sy = 1,
    }
  end

  weapon.animation = weapon.defaultAnimation

  weapon.damage = node.properties.damage or weapon.props.damage or 1
  -- Damage that does not affect all enemies ie. stab, fire
  weapon.special_damage = weapon.props.special_damage or {}
  weapon.knockback = node.properties.knockback or weapon.props.knockback or 10
  weapon.dead = false

  --create the bounding box
  weapon:initializeBoundingBox(collider)

  -- Represents direction of the weapon when no longer in the players inventory
  weapon.direction = node.properties.direction or 'right'
  weapon.flipY = node.properties.flipY or 'false'

  --audio clip when weapon is put away
  weapon.unuseAudioClip = node.properties.unuseAudioClip or
              weapon.props.unuseAudioClip or
              'sword_sheathed'

  --audio clip when weapon hits something
  weapon.hitAudioClip = node.properties.hitAudioClip or
              weapon.props.hitAudioClip or
              nil

  --audio clip when weapon swing through air
  weapon.swingAudioClip = node.properties.swingAudioClip or
              weapon.props.swingAudioClip or
              nil

  weapon.action = weapon.props.action or 'wieldaction'
  weapon.dropping = false
  weapon.dropped = false

  if weapon.player and weapon.props.trigger then
    weapon.db = app.gamesaves:active()
    local trigger = weapon.db:get( weapon.name .. '-trigger', false)
    if not trigger then
      weapon.props.trigger(weapon)
      weapon.db:set( weapon.name .. '-trigger', true)
    end
  end

  return weapon
end

---
-- Draws the weapon to the screen
-- @return nil
function Weapon:draw()
  if self.dead then return end

  local scalex = 1
  if self.player then
    if self.player.character.direction=='left' then
      scalex = -1
      self.direction = 'left'
    else
      self.direction = 'right'
    end
  elseif self.direction == 'left' then
    scalex = -1
  end

  local scaley = 1
  local offsetY = 0
  if self.flipY == 'true' then
    scaley = -1
    offsetY = self.boxHeight or 0
  end

  -- Flipping an image moves it, this adjust for that image flip offset
  local offsetX = 0
  if not self.player and self.direction == 'left' then
    offsetX = self.boxWidth or 0
  end

  if self.image then
    love.graphics.draw(self.image, self.position.x + offsetX, self.position.y + offsetY, 0, scalex, scaley)
    return
  end

  local animation = self.animation
  if not animation then return end
  animation:draw(self.sheet, math.floor(self.position.x) + offsetX, self.position.y + offsetY, 0, scalex, scaley)
end

---
-- Called when the weapon begins colliding with another node
-- @return nil
function Weapon:collide(node, dt, mtv_x, mtv_y)
  if not node or self.dead or (self.player and not self.player.wielding) or self.dropped then return end
  if node.isPlayer then return end

  if self.dropping and (node.isFloor or node.floorspace or node.isPlatform) then
    self.dropping = false
  end

  if node.hurt and self.player then
    local knockback = self.player.character.direction == 'right' and self.knockback or -self.knockback
    node:hurt(self.damage, self.special_damage, knockback)
    self.collider:setGhost(self.bb)
  end

  if self.hitAudioClip and node.hurt then
    sound.playSfx(self.hitAudioClip)
  end

end

function Weapon:initializeBoundingBox(collider)
  self.boxTopLeft = {x = self.position.x,
            y = self.position.y}
  self.boxWidth = self.bbox_width
  self.boxHeight = self.bbox_height

  --update the collider using the bounding box
  self.bb = collider:addRectangle(self.boxTopLeft.x,self.boxTopLeft.y,self.boxWidth,self.boxHeight)
  self.bb.node = self
  self.collider = collider

  if self.player then
    self.collider:setGhost(self.bb)
  else
    self.collider:setSolid(self.bb)
  end
end

---
-- Called when the weapon is returned to the inventory
function Weapon:deselect()
  self.dead = true
  self.collider:remove(self.bb)
  self.containerLevel:removeNode(self)
  self.player.wielding = false
  self.player.currently_held = nil
  local state = self.player.isClimbing and 'climbing' or 'default'
  self.player:setSpriteStates(state)

  sound.playSfx(self.unuseAudioClip)
end

--default update method
--overload this in the specific weapon if this isn't well-suited for your weapon
function Weapon:update(dt, player, map)
  if self.dead then return end

  --the weapon is in the level unclaimed
  if not self.player then
    if self.dropping then
      -- Need to add an offset for dropping
      local nx, ny = collision.move(map, self, self.position.x + self.bbox_offset_x[1],
                      self.position.y,
                      self.dropWidth, self.dropHeight, 
                      self.velocity.x * dt, self.velocity.y * dt)
      self.position.x = nx - self.bbox_offset_x[1]
      self.position.y = ny

      self.velocity = {x = self.velocity.x,
               y = self.velocity.y + game.gravity*dt}
               
      local offset_x = 0

      if self.bbox_offset_x then
        offset_x = self.bbox_offset_x[1]
      end
      if self.bb then
        self.bb:moveTo(self.position.x + offset_x + self.dropWidth / 2,
                 self.position.y + self.dropHeight / 2)
      end
    end

    -- Item has finished dropping in the level
    if not self.dropping and self.dropped and not self.saved then
      self.containerLevel:saveAddedNode(self)
      self.saved = true
    end
  else
    --the weapon is being used by a player
    local player = self.player
    local plyrOffset = player.width/2

    if not self.position or not self.position.x or not player.position or not player.position.x then return end

    local framePos = (player.wielding) and self.animation.position or 1
    if player.character.direction == "right" then
      self.position.x = math.floor(player.position.x) + (plyrOffset-self.hand_x) +player.offset_hand_left[1] - player.character.bbox.x
      self.position.y = math.floor(player.position.y) + (-self.hand_y) + player.offset_hand_left[2] - player.character.bbox.y
      if self.bb then
        self.bb:moveTo(self.position.x + (self.bbox_offset_x[framePos] or 0) + self.bbox_width/2,
                 self.position.y + (self.bbox_offset_y[framePos] or 0) + self.bbox_height/2)
      end
    else
      self.position.x = math.floor(player.position.x) + (plyrOffset+self.hand_x) +player.offset_hand_right[1] - player.character.bbox.x
      self.position.y = math.floor(player.position.y) + (-self.hand_y) + player.offset_hand_right[2] - player.character.bbox.y

      if self.bb then
        self.bb:moveTo(self.position.x - (self.bbox_offset_x[framePos] or 0) - self.bbox_width/2,
                 self.position.y + (self.bbox_offset_y[framePos] or 0) + self.bbox_height/2)
      end
    end

    if player.offset_hand_right[1] == 0 or player.offset_hand_left[1] == 0 then
      --print(string.format("Need hand offset for %dx%d", player.frame[1], player.frame[2]))
    end
    if self.magical then
      if not self.charged then
        self.chargeUpTime = self.chargeUpTime + dt
        if self.chargeUpTime >= 10 then
          self.chargeUpTime = 0
          self.charged = true
        end
      else
        self.animation = self.defaultChargedAnimation
      end
    end

    if player.wielding and self.animation and self.animation.status == "finished" then
      if self.bb then
        self.collider:setGhost(self.bb)
      end
      player.wielding = false
      self.animation = self.defaultAnimation
    end
  end
  if self.animation then
    self.animation:update(dt)
  end

  local shake = 0
  local current = gamestate.currentState()
  if self.shake and current.trackPlayer == false then
    shake = (math.random() * 4) - 2
    camera:setPosition(self.camera.tx + shake, self.camera.ty + shake)
  end

  if self.props and self.props.update then
    self.props.update(self, dt, player, map)
  end
end

function Weapon:keypressed( button, player)
  if self.player then return end

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

--handles a weapon being activated
function Weapon:wield()
  if self.props.wield then self.props.wield(self) end

  self.collider:setSolid(self.bb)

  self.player.wielding = true

  if self.animation then
    self.animation = self.wieldAnimation
    self.animation:gotoFrame(1)
    self.animation:resume()
  end

  self.player.character.state = self.action
  self.player.character:animation():gotoFrame(1)
  self.player.character:animation():resume()

  if self.swingAudioClip then
    sound.playSfx( self.swingAudioClip )
  end

end

-- handles weapon being dropped in the real world
function Weapon:drop(player)
  self.collider:remove(self.bb)
  self.bb = self.collider:addRectangle(self.position.x,self.position.y,self.dropWidth,self.dropHeight)
  self.bb.node = self
  self.collider:setSolid(self.bb)
  -- need to offset
  self.position.x = self.position.x - self.bbox_offset_x[1]
  if player.footprint then
    self:floorspace_drop(player)
    return
  end
  self.dropping = true
  self.dropped = true
end

function Weapon:throwProjectile( weapon )
  if self.props.throwProjectile then self.props.throwProjectile(self) end
end

function Weapon:weaponShake( weapon )
  if self.props.weaponShake then self.props.weaponShake(self) end
end


-- handle weapon being dropped in a floorspace
function Weapon:floorspace_drop(player)
  self.position.y = player.footprint.y - self.dropHeight

  if self.bbox_offset_x then
    offset_x = self.bbox_offset_x[1]
  end

  self.bb:moveTo(self.position.x + offset_x + self.dropWidth / 2, self.position.y + self.dropHeight / 2)

  self.containerLevel:saveAddedNode(self)
end

function Weapon:floor_pushback()
  if not self.dropping then return end

  local offset_x = 0

  self.dropping = false
  if self.bbox_offset_x then
    offset_x = self.bbox_offset_x[1]
  end
  if self.bb then
    self.bb:moveTo(self.position.x + offset_x + self.dropWidth / 2,
             self.position.y + self.dropHeight / 2)
  end

  self.velocity.y = 0
end

return Weapon