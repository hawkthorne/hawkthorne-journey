local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'
local utils = require 'utils'
local Timer = require 'vendor/timer'
local anim8 = require 'vendor/anim8'
local gamestate = require 'vendor/gamestate'

local HUD = {}
HUD.__index = HUD

local savingImage = love.graphics.newImage('images/hud/saving.png')

savingImage:setFilter('nearest', 'nearest')

function HUD.new(level)
  local hud = {}
  setmetatable(hud, HUD)

  local character = level.player.character

hud.money = love.graphics.newImage('images/hud/money.png')
  
  hud.saving = false
  hud.savingImage = love.graphics.newImage('images/hud/saving.png')
  local h = anim8.newGrid(17, 16, hud.savingImage:getDimensions())
  hud.savingAnimation = anim8.newAnimation('loop', h('1-7,1'), 0.1, {[7] = 0.4})
  hud.savingAnimation:pause()
  hud.invincible = false
  hud.invincibleImage = love.graphics.newImage('images/hud/invincible.png')
  local i = anim8.newGrid(19, 19, hud.invincibleImage:getDimensions())
  hud.invincibleAnimation = anim8.newAnimation('loop', i('1-6,1'), 0.2, {[6] = 0.2})
  hud.invincibleAnimation:pause()
  hud.restricted = false
  hud.restrictedImage = love.graphics.newImage('images/hud/restricted.png')
  local h = anim8.newGrid(19, 19, hud.restrictedImage:getDimensions())
  hud.restrictedAnimation = anim8.newAnimation('loop', h('1-2,1'), 0.1, {[2] = 0.4})
  hud.restrictedAnimation:pause()
  hud.punchDamage = false
  hud.punchDamageImage = love.graphics.newImage('images/hud/punchDamage.png')
  local i = anim8.newGrid(19, 19, hud.punchDamageImage:getDimensions())
  hud.punchDamageAnimation = anim8.newAnimation('loop', i('1-9,1'), 0.1, {[9] = 0.1})
  hud.punchDamageAnimation:pause()
  hud.jumpDamage = false
  hud.jumpDamageImage = love.graphics.newImage('images/hud/jumpDamage.png')
  local i = anim8.newGrid(19, 19, hud.jumpDamageImage:getDimensions())
  hud.jumpDamageAnimation = anim8.newAnimation('loop', i('1-9,1'), 0.1, {[9] = 0.1})
  hud.jumpDamageAnimation:pause()
  hud.jumpFactor = false
  hud.jumpFactorImage = love.graphics.newImage('images/hud/jumpFactor.png')
  local i = anim8.newGrid(19, 19, hud.jumpFactorImage:getDimensions())
  hud.jumpFactorAnimation = anim8.newAnimation('loop', i('1-11,1'), 0.1, {[11] = 0.1})
  hud.jumpFactorAnimation:pause()
  hud.speedFactor = false
  hud.speedFactorImage = love.graphics.newImage('images/hud/speedFactor.png')
  local i = anim8.newGrid(19, 19, hud.speedFactorImage:getDimensions())
  hud.speedFactorAnimation = anim8.newAnimation('loop', i('1-8,1'), 0.1, {[8] = 0.1})
  hud.speedFactorAnimation:pause()


  hud.quest = love.graphics.newImage('images/hud/quest.png') 

  return hud
end

function HUD:startSave()
  self.saving = true
  self.savingAnimation:gotoFrame(1)
  self.savingAnimation:resume()
end

function HUD:endSave()
  Timer.add(2, function()
      self.saving = false
      self.savingAnimation:pause()
  end)
end

function HUD:update(dt)
  if self.saving then
    self.savingAnimation:update(dt)
  end
  if self.invincible then
    self.invincibleAnimation:update(dt)
  end
  if self.punchDamage then
    self.punchDamageAnimation:update(dt)
  end
  if self.jumpDamage then
    self.jumpDamageAnimation:update(dt)
  end
  if self.jumpFactor then
    self.jumpFactorAnimation:update(dt)
  end
  if self.speedFactor then
    self.speedFactorAnimation:update(dt)
  end
end

function HUD:rwrc(x, y, w, h, r)
  local right = 0
  local left = math.pi
  local bottom = math.pi * 0.5
  local top = math.pi * 1.5
  r = r or 15
  love.graphics.rectangle("fill", x, y+r, w, h-r*2)
  love.graphics.rectangle("fill", x+r, y, w-r*2, r)
  love.graphics.rectangle("fill", x+r, y+h-r, w-r*2, r)
  love.graphics.arc("fill", x+r, y+r, r, left, top)
  love.graphics.arc("fill", x + w-r, y+r, r, -bottom, right)
  love.graphics.arc("fill", x + w-r, y + h-r, r, right, bottom)
  love.graphics.arc("fill", x+r, y + h-r, r, bottom, left)
end

function HUD:draw( player )
  if not window.dressing_visible then
    return
  end

  fonts.set('small')

  local x, y = camera.x, camera.y
  
  --ACTIVE POTION & CONSUMABLE EFFECTS
  love.graphics.setColor( 255, 255, 255, 255 )
  
  local iconX, iconY = x + 4, y + 50
  local icons = 0
  local iconline = 0


  
  if player.godmode or player.invulnerable then --TODO: don't show up when getting hurt
    if player.consuming then
      self.invincible = true
      self.invincibleAnimation:draw(self.invincibleImage, iconX + 20*icons, iconY+(iconline*19))
      self.invincibleAnimation:resume()
      icons = icons + 1
      print(iconline)
    end
  end
  
  if player.jumpFactor  > 1 then
    self.jumpFactor = true
    self.jumpFactorAnimation:draw(self.jumpFactorImage, iconX + 20*icons, iconY+(iconline*19))
    self.jumpFactorAnimation:resume()
    icons = icons + 1
  end
  
  if player.speedFactor  > 1 then
    self.speedFactor = true
    self.speedFactorAnimation:draw(self.speedFactorImage, iconX + 20*icons, iconY+(iconline*19))
    self.speedFactorAnimation:resume()
    icons = icons + 1
  end

  if player.jumpFactor == 0 or player.speedFactor == 0 then
    self.restricted = true
    self.restrictedAnimation:draw(self.restrictedImage, iconX + 20*icons, iconY+(iconline*19))
    self.restrictedAnimation:resume()
    icons = icons + 1
  end
  
  if player.punchDamage > 1 then
    self.punchDamage = true
    self.punchDamageAnimation:draw(self.punchDamageImage, iconX + 20*icons, iconY+(iconline*19))
    self.punchDamageAnimation:resume()
    icons = icons + 1
  end

  if player.jumpDamage > 3 then
    self.jumpDamage = true
    self.jumpDamageAnimation:draw(self.jumpDamageImage, iconX + 20*icons, iconY+(iconline*19))
    self.jumpDamageAnimation:resume()
    icons = icons + 1
  end

  if icons > 2 and icons < 5 then
    iconline = 1
  end
  --TODO: add slide damage


  -- BACKGROUND
  local current = gamestate.currentState()
  if current.brightness ~= 'light' then
     love.graphics.setColor( 255, 255, 255, 100 )
    HUD:rwrc(x+2, y+2, 40, 70, 2)
    love.graphics.setColor( 0, 0, 0, 100 )
    HUD:rwrc(x+4, y+30, 17, 17, 2)
  else
    love.graphics.setColor( 0, 0, 0, 100 )
    HUD:rwrc(x+2, y+2, 40, 70+(19*iconline), 2)
    love.graphics.setColor( 255, 255, 255, 100 )
    HUD:rwrc(x+4, y+30, 17, 17, 2)
  end
  love.graphics.setColor( 255, 255, 255, 255 )
  

  -- MONEY
  love.graphics.print(player.money, x+12, y + 6)
  love.graphics.draw(self.money, x+2 , y + 4)
  
  -- HEALTH 
  love.graphics.setColor(
    math.min(utils.map(player.health, player.max_health, player.max_health / 2 + 1, 0, 255 ), 255 ), -- green to yellow
    math.min(utils.map(player.health, player.max_health / 2, 0, 255, 0), 255), -- yellow to red
    0,
    255
  )

    love.graphics.rectangle("fill", x+4, y+20, 35-(player.max_health - player.health) * .35, 3 )
  love.graphics.setColor( 0, 0, 0, 255 )
  love.graphics.rectangle("line", x+4, y+20, 35-(player.max_health - player.health) * .35, 3 )
  love.graphics.setColor( 255, 255, 255, 255 )

  -- WEAPONS
  local currentWeapon = player.inventory:currentWeapon()
  if currentWeapon and not player.doBasicAttack or (player.holdingAmmo and currentWeapon) then
    currentWeapon:drawHud(x + 5, y + 31, true)
  end
  --SAVING
  if self.saving then
    self.savingAnimation:draw(self.savingImage, x + 23, y + 31)
  end

  --QUESTS
  if player.quest ~= nil then
    love.graphics.draw(self.quest, x+26, y+31)
  end

    --SAVING
  if self.saving then
    self.savingAnimation:draw(self.savingImage, x + 23, y + 31)
  end
  

  fonts.revert()
end

return HUD
