------------------------------
-- Generic enemy node
-- Written by G3nius
-- Refactor by jhoff
--
-- Add a node to the .tmx of 'type' == 'enemy'
--    with an 'enemytype' property set to the type of enemy ( I.E. 'hippy' / 'frog' / etc )
-- You must create a src/nodes/enemies file to define unique
--    animation frames, movement function and additional properties.
------------------------------

local collision  = require 'hawk/collision'
local gamestate = require 'vendor/gamestate'
local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local tween = require 'vendor/tween'
local cheat = require 'cheat'
local sound = require 'vendor/TEsound'
local token = require 'nodes/token'
local game = require 'game'
local utils = require 'utils'
local window = require 'window'
local app = require 'app'
local player = require 'player'
local Player = player.factory()


local Enemy = {}
Enemy.__index = Enemy
Enemy.isEnemy = true

function Enemy.new(node, collider, enemytype)
  local enemy = {}
  setmetatable(enemy, Enemy)
  enemy.minimum_x = -math.huge -- -3000
  enemy.minimum_y = -math.huge -- -3000
  enemy.maximum_x = math.huge -- 30000
  enemy.maximum_y = math.huge -- 2000
  
  local type = node.properties.enemytype or enemytype
  
  enemy.type = type
  
  enemy.props = utils.require('nodes/enemies/' .. type)
  local sprite_sheet
  if node.properties.sheet then
    sprite_sheet = 'images/enemies/' .. node.properties.sheet .. '.png'
  else
    sprite_sheet = 'images/enemies/' .. type .. '.png'
  end
  enemy.sprite = love.graphics.newImage( sprite_sheet )
  enemy.sprite:setFilter('nearest', 'nearest')
  
  enemy.grid = anim8.newGrid( enemy.props.width, enemy.props.height, enemy.sprite:getWidth(), enemy.sprite:getHeight() )
  
  enemy.node_properties = node.properties
  enemy.node = node
  enemy.collider = collider
  enemy.maxx = 0
  enemy.minx = 0
  enemy.range = enemy.props.range or 0
  enemy.dead = false
  enemy.dying = false
  enemy.idletime = 0
  enemy.db = app.gamesaves:active()
  assert( enemy.props.damage, "You must provide a 'damage' value for " .. type )

  assert( enemy.props.hp, "You must provide a 'hp' ( hit point ) value for " .. type )
  assert( tonumber(enemy.props.hp),"Hp must be a number" )
  enemy.hp = tonumber(enemy.props.hp)
  
  enemy.height = enemy.props.height
  enemy.width = enemy.props.width
  enemy.bb_width = enemy.props.bb_width or enemy.width
  enemy.bb_height = enemy.props.bb_height or enemy.height
  enemy.position_offset = enemy.props.position_offset or {x=0,y=0}
  
  -- Height to be used when offsetting an enemy to its node
  local height = node.height or enemy.height
  
  -- adjust position so bottom is lined up with node bottom
  enemy.position = {
    x = node.x + ( enemy.position_offset.x or 0),
    y = node.y + height - enemy.height + ( enemy.position_offset.y or 0)
  }
  --enemy.velocity = enemy.props.velocity or {x=0,y=0}
  enemy.velocity = {
    x = node.velocityX or (node.velocity and node.velocity.x) or 0,
    y = node.velocityY or (node.velocity and node.velocity.y) or 0
  }
  
  enemy.last_jump = 0
  
  enemy.jumpkill = enemy.props.jumpkill
  if enemy.jumpkill == nil then enemy.jumpkill = true end
  enemy.jumpBounce = enemy.props.jumpBounce or false
  
  enemy.dyingdelay = enemy.props.dyingdelay and enemy.props.dyingdelay or 0.75
  enemy.revivedelay = enemy.props.revivedelay and enemy.props.revivedelay or .5
  
  enemy.state = 'default'
  enemy.direction = node.properties.direction or 'left'
  enemy.offset_hand_right = {}
  enemy.offset_hand_right[1] = enemy.props.hand_x or enemy.width/2
  enemy.offset_hand_right[2] = enemy.props.hand_y or enemy.height/2
  enemy.chargeUpTime = enemy.props.chargeUpTime
  enemy.player_rebound = enemy.props.player_rebound or 300
  enemy.vulnerabilities = enemy.props.vulnerabilities or {}

  enemy.attackingWorld = false

  enemy.burn = false
  enemy.knockbackDisabled = enemy.props.knockbackDisabled or false

  enemy.fadeIn = enemy.props.fadeIn or false
  enemy.fade = {255, 255, 255, 0}
  enemy.animations = {}
  
  for state, data in pairs( enemy.props.animations ) do
    enemy.animations[state] = {}
    for dir, a in pairs( data ) do
      enemy.animations[ state ][ dir ] = anim8.newAnimation( a[1], enemy.grid( unpack(a[2]) ), a[3])
    end
  end
  
  enemy.bb = collider:addRectangle(node.x, node.y, 
                                   enemy.props.bb_width or enemy.props.width,
                                   enemy.props.bb_height or enemy.props.height)
  enemy.bb.node = enemy
  enemy.bb_offset = enemy.props.bb_offset or {x=0,y=0}
  
  enemy.quest = node.properties.quest
  enemy.drop = node.properties.drop
  if enemy.quest and Player.quest ~= enemy.quest then
    enemy:die(true)
  end
  if enemy.props.passive then
    collider:setGhost(enemy.bb)
  end
  
  if enemy.props.attack_bb then
    enemy.attack_bb = collider:addRectangle(node.x, node.y,
                                            enemy.props.attack_width or enemy.props.width,
                                            enemy.props.attack_height or enemy.props.height)
    enemy.attack_bb.node = enemy
    enemy.attack_offset = enemy.props.attack_offset or {x=0,y=0}
    collider:setGhost(enemy.attack_bb)
    enemy.last_attack = 0
  end

  enemy.foreground = node.properties.foreground or enemy.props.foreground or false
  enemy.db = app.gamesaves:active()
  
  return enemy
end

function Enemy:enter()
  if self.props.enter then
    self.props.enter(self)
  end
end

function Enemy:leave()
  if self.props.leave then
    self.props.leave(self)
  end
end

function Enemy:animation()
  if self.state == 'hidden' then return end
  if self.animations[self.state] == nil then
    print( string.format( "Warning: No animation supplied for %s::%s", self.type, self.state ) );
    return self.animations["default"][self.direction]
  else
    return self.animations[self.state][self.direction]
  end
end

function Enemy:hurt( damage, special_damage, knockback )
  if self.dead or self.invulnerable or self.state == 'hidden'  then return end
  if self.props.die_sound then sound.playSfx( self.props.die_sound ) end

  if not damage then damage = 1 end
  
  if not self.rage then
    self.state = 'hurt'
  end
  -- Subtract from hp total damage including special damage
  self.hp = self.hp - self:calculateDamage(damage, special_damage)

  if self.hp <= 0 then
    self.state = 'dying'
    self.dying = true
    self:cancel_flash()

    if self.containerLevel and self.props.splat then
      table.insert(self.containerLevel.nodes, 5, self.props.splat(self))
    end

    if self.props.prevent_death then
      local alive = self.props.prevent_death( self )
      if alive then
        self.state = 'before_death'
        self.dying = false
        self.dead = false
        self.invulnerable = true
        self.props.peaceful = true
        self.hp = 1
        return
      end
    end

    self.collider:setGhost(self.bb)
    self.collider:setGhost(self.attack_bb)
    
    if self.currently_held then
      self.currently_held:die()
    end
    Timer.add(self.dyingdelay, function()
      local level = gamestate.currentState()
      if self.containerLevel and self.containerLevel.name ~= level.name then return end
      self:die()
    end)
    if self.reviveTimer then Timer.cancel( self.reviveTimer ) end
    self:dropTokens()
  else
    if knockback and not self.knockbackDisabled and not self.knockbackActive then
      self.knockbackActive = true
      tween.start(0.5, self.position,
              {x = self.position.x + (knockback or 0) * (self.props.knockback or 1)},
              'outCubic',
              function() self.knockbackActive = false end)
    end
    if not self.flashing and not self.rage then
      self:start_flash()
    end
    if self.props.hurt then self.props.hurt( self ) end
  end
end

-- Compares vulnerabilities to a weapons special damage and sums up total damage
function Enemy:calculateDamage(damage, special_damage)
  if not special_damage then
    return damage
  end
  for _, value in ipairs(self.vulnerabilities) do
    if special_damage[value] ~= nil then
      damage = damage + special_damage[value]
    end
  end

  return damage
end

function Enemy:start_flash()
  if not self.blink then
    self.blink = Timer.addPeriodic(.12, function()
      self.flash = not self.flash
    end, math.ceil(self.revivedelay / .12))
  end
  if self.reviveTimer then Timer.cancel( self.reviveTimer ) end
  self.reviveTimer = Timer.add( self.revivedelay, function()
                                self.state = 'default'
                                self:cancel_flash()
                                self.flashing = false
                                end )
  self.flashing = true
end

function Enemy:cancel_flash()
  self.flashing = false
  if self.blink then
    Timer.cancel(self.blink)
    self.blink = nil
  end
  self.flash = false
end

-- The hide variable will be set to true when the die function is being
-- used to hide the enemy and they player didn't actually kill it
function Enemy:die(hide)
  if self.props.die then self.props.die( self ) end
  
  if self.props.isBoss and not hide then
    Player:bossKilled(self.type == 'cornelius')
  end

  if self.drop and Player.quest == self.quest and not Player.inventory:hasKey(self.drop) then
    local NodeClass = require('nodes/key')
    local node = {
      type = 'key',
      name = self.drop,
      x = self.position.x,
      y = self.position.y + self.height - 24,
      width = 24,
      height = 24,
      properties = {info = "This must be the technology that the alien wants!"},
    }
    local spawnedNode = NodeClass.new(node, self.collider)
    local level = gamestate.currentState()
    level:addNode(spawnedNode)
  end

  self.dead = true
  self.collider:remove(self.bb)
  self.collider:remove(self.attack_bb)
  self.bb = nil
  self.attack_bb = nil
  if self.containerLevel then
    self.containerLevel:removeNode(self)
  end
end

function Enemy:dropTokens()
  if not self.props.tokens or self.props.tokens == 0 then return end
  
  for i=1, self.props.tokens do
    local r = math.random(100) / 100
    for _,d in pairs( self.props.tokenTypes ) do
      if r < d.p then
        local node = {
          type = "token",
          name = d.item,
          x = self.position.x + self.props.width / 2,
          y = self.position.y + self.props.height,
          width = 24,
          height = 24,
          properties = {
            life = 5,
            value = d.v
          }
        }
        local token = token.new(node,self.collider)
        self.containerLevel:addNode(token)
        break
      end
    end
  end
end

function Enemy:collide(node, dt, mtv_x, mtv_y)
  if self.state == 'hidden' then return end
  function attack()
    if self.props.attack_sound then
      if not self.attackingWorld then
        if type(self.props.attack_sound) == 'table' then
          sound.playSfx( self.props.attack_sound[math.random(#self.props.attack_sound)] )
        else
          sound.playSfx( self.props.attack_sound )
        end
      end
    end

    if (node.isPlayer or node.isWall) and self.type == "cornelius" and self.hp == 1 then return end

    if self.props.attack then
      self.props.attack(self,self.props.attackDelay)
    elseif self.animations['attack'] then
      self.state = 'attack'
      Timer.add(1, function()
        if self.state ~= 'dying' then self.state = 'default' end
      end)
    end
  end

  if node.isWall then
    if self.type ~= "benzalkBoss" then
      attack()
    end

    if self.props.damage ~= 0 then
      if self.attackingWorld then return end
      if self.type ~= "cornelius" then
        self.attackingWorld = true
        Timer.add(1.25, function()
          self.attackingWorld = false
        end)
      end
      node:hurt(self.props.damage, self.props.special_damage)
    end
  end

  if not node.isPlayer or 
     self.props.peaceful or
     self.dead or
     node.dead then return end

  local player = node
  if player.rebounding or player.dead then
    player.current_enemy = nil
    return
  end

  if not player.current_enemy then
     player.current_enemy = self
  end

  if player.current_enemy ~= self then 
    player.velocity.x = -player.velocity.x/100
  return end
  
  local _, _, _, playerBottom = player.bottom_bb:bbox()
  local _, enemyTop, _, y2 = self.bb:bbox()
  local headsize = 3*(y2 - enemyTop) / 4

  if playerBottom >= enemyTop and (playerBottom - enemyTop) < headsize
    and player.velocity.y > self.velocity.y and self.jumpkill then
    -- successful attack
    self:hurt(player.jumpDamage)
    -- reset fall damage when colliding with an enemy
    player.fall_damage = 0
    if self.jumpBounce then
      player.velocity.y = -750 * player.jumpFactor
    else
      player.velocity.y = -450 * player.jumpFactor
    end
  end

  if cheat:is('god') then
    self:hurt(self.hp)
    return
  end

  if player.invulnerable or self.state == 'dying' or self.state == 'hurt' then
    return
  end

  -- attack
  attack()

  if self.props.damage ~= 0 then
    player:hurt(self.props.damage)
    player.top_bb:move(mtv_x, mtv_y)
    player.bottom_bb:move(mtv_x, mtv_y)
    player.velocity.y = -450
    player.velocity.x = self.player_rebound * ( player.position.x < self.position.x + ( self.props.width / 2 ) + self.bb_offset.x and -1 or 1 )
  end
end

function Enemy:collide_end( node )
  if node and node.isPlayer and node.current_enemy == self then
    node.current_enemy = nil
  end
end

function Enemy:update( dt, player, map )
  if self.state == 'hidden' then return end
  local level = gamestate.currentState()
  if level.scene or player.inventory.visible or self.state == 'hidden' then return end
  
  if(self.position.x < self.minimum_x or self.position.x > self.maximum_x or
     self.position.y < self.minimum_y or self.position.y > self.maximum_y) then
      self:die()
  end
  
  if self.dead then return end

  if not self.flashing then
    self:cancel_flash()
  end

  self:animation():update(dt)
  if self.state == 'dying' then
    if self.props.dyingupdate then
      self.velocity.y = 0
      self.props.dyingupdate( dt, self )
    end
    return
  end

  -- passive sound
  if self.props.passive_sound then
    if (math.random() <= (self.props.passive_sound_chance or .05) * dt) and (self.state == 'default') and self:onScreen() then
      if type(self.props.passive_sound) == 'table' then
        sound.playSfx( self.props.passive_sound[math.random(#self.props.passive_sound)] )
      else
        sound.playSfx( self.props.passive_sound )
      end
    end
  end
  
  if self.props.update then
    self.props.update( dt, self, player )
  end
  
  if not self.props.antigravity and not self.dying then
    -- Gravity
    self.velocity.y = self.velocity.y + game.gravity * dt
    if self.velocity.y > game.max_y then
      self.velocity.y = game.max_y
    end
  end
  
  self:updatePosition(map, self.velocity.x * dt, self.velocity.y * dt)
  
  self:moveBoundingBox()
end

function Enemy:updatePosition(map, dx, dy)
  local offset_x = self.width/2 - self.bb_width / 2 + self.bb_offset.x
  local offset_y = self.height/2 + self.bb_offset.y - self.bb_height/2
  
  local nx, ny = collision.move(map, self, self.position.x + offset_x,
                                self.position.y + offset_y,
                                self.bb_width, self.bb_height,
                                -dx, dy)

  self.position.x = nx - offset_x
  self.position.y = ny - offset_y
end

function Enemy:draw()
  if self.state == 'hidden' then return end

  local r, g, b, a = love.graphics.getColor()

  if self.flash then
    love.graphics.setColor(255, 0, 0, 255)
  elseif self.fadeIn then
    tween(2, self.fade, {255, 255, 255, 255}, 'outQuad', function() self.fadeIn = false end)
    love.graphics.setColor(unpack(self.fade))
  else
    love.graphics.setColor(255, 255, 255, 255)
  end

  if not self.dead then
    self:animation():draw( self.sprite, math.floor( self.position.x ), math.floor( self.position.y ) )
  end

  love.graphics.setColor(r, g, b, a)

  if self.props.draw then
    self.props.draw(self)
  end
end

function Enemy:ceiling_pushback()
  if self.props.ceiling_pushback then
    self.props.ceiling_pushback(self)
  end
end

function Enemy:floor_pushback()
  self.velocity.y = 0
  if self.props.floor_pushback then
    self.props.floor_pushback(self)
  else
    self:moveBoundingBox()
  end
end

function Enemy:wall_pushback()
  if self.props.wall_pushback then
    self.props.wall_pushback(self)
  else
    if self.attackingWorld then return end
    self.direction = self.direction == 'left' and 'right' or 'left'
    -- self.velocity.x = 0
    self:moveBoundingBox()
  end
end

function Enemy:moveBoundingBox()
  if not self.bb then
    -- We should never get to this state, but we somehow do
    return
  end

  self.bb:moveTo( self.position.x + ( self.props.width / 2 ) + self.bb_offset.x,
          self.position.y + ( self.props.height / 2 ) + self.bb_offset.y )

  if self.attack_bb then
    local width = self.direction == 'right' and self.props.bb_width or -40
    self.attack_bb:moveTo( self.position.x + ( self.props.width / 2 ) + self.attack_offset.x + width,
                 self.position.y + ( self.props.height / 2 ) + self.attack_offset.y )
  end
end

---
-- Registers an object as something that the user can currently hold on to
-- @param holdable
-- @return nil
function Enemy:registerHoldable(holdable)
  if self.holdable == nil and self.currently_held == nil and holdable.holder == nil then
    self.holdable = holdable
  end
end

---
-- Cancels the holdability of a node
-- @param holdable
-- @return nil
function Enemy:cancelHoldable(holdable)
  if self.holdable == holdable then
    self.holdable = nil
  end
end

function Enemy:pickup()
  if not self.holdable or self.currently_held then return end
  
  local obj
  if self.holdable.pickup then
    obj = self.holdable:pickup(self)
  end
  if obj then self.holdable = nil end
  self.currently_held = obj
end

-- Throws an object.
-- @return nil
function Enemy:throw()
  if self.currently_held then
    local object_thrown = self.currently_held
    self.currently_held = nil
    if object_thrown.throw then
      object_thrown:throw(self)
    end
  end
end

function Enemy:onScreen()
  x_min, y_min = self.containerLevel:cameraPosition()
  x_max = x_min + window.width
  y_max = y_min + window.height
  if self.position.x >= x_min and self.position.x <= x_max then
    if self.position.y >= y_min and self.position.y <= y_max then
      return true
    end
  end
  return false
end

return Enemy
