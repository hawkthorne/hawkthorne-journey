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
  hud.heart_full = love.graphics.newImage('images/hud/health_full.png')

  hud.saving = false
  hud.savingImage = love.graphics.newImage('images/hud/saving.png')
  local h = anim8.newGrid(17, 16, hud.savingImage:getDimensions())
  hud.savingAnimation = anim8.newAnimation('loop', h('1-7,1'), 0.1, {[7] = 0.4})
  hud.savingAnimation:pause()
  
  hud.invincible = false
  hud.invincibleImage = love.graphics.newImage('images/hud/invincible.png')
  local i = anim8.newGrid(16, 17, hud.invincibleImage:getDimensions())
  hud.invincibleAnimation = anim8.newAnimation('loop', i('1-2,1'), 0.1, {[2] = 0.1})
  hud.invincibleAnimation:pause()

  hud.restricted = false
  hud.restrictedImage = love.graphics.newImage('images/hud/restricted.png')
  local h = anim8.newGrid(19, 19, hud.restrictedImage:getDimensions())
  hud.restrictedAnimation = anim8.newAnimation('loop', h('1-2,1'), 0.1, {[2] = 0.4})
  hud.restrictedAnimation:pause()

  hud.punchDamage = false
  hud.punchDamageImage = love.graphics.newImage('images/hud/punchDamage.png')
  local i = anim8.newGrid(16, 17, hud.punchDamageImage:getDimensions())
  hud.punchDamageAnimation = anim8.newAnimation('loop', i('1-2,1'), 0.1, {[2] = 0.1})
  hud.punchDamageAnimation:pause()

  hud.jumpFactor = false
  hud.jumpFactorImage = love.graphics.newImage('images/hud/jumpFactor.png')
  local i = anim8.newGrid(16, 17, hud.jumpFactorImage:getDimensions())
  hud.jumpFactorAnimation = anim8.newAnimation('loop', i('1-2,1'), 0.1, {[2] = 0.1})
  hud.jumpFactorAnimation:pause()

  hud.speedFactor = false
  hud.speedFactorImage = love.graphics.newImage('images/hud/speedFactor.png')
  local i = anim8.newGrid(16, 17, hud.speedFactorImage:getDimensions())
  hud.speedFactorAnimation = anim8.newAnimation('loop', i('1-2,1'), 0.1, {[2] = 0.1})
  hud.speedFactorAnimation:pause()


  hud.quest = false 

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
  if self.jumpFactor then
    self.jumpFactorAnimation:update(dt)
  end
  if self.speedFactor then
    self.speedFactorAnimation:update(dt)
  end
end

function HUD:draw( player )
  if not window.dressing_visible then
    return
  end

  fonts.set('small')

  local x, y = camera.x, camera.y

  -- HEALTH 
  love.graphics.draw(self.heart_full, x+4 , y + 4)
  love.graphics.setColor(
    math.min(utils.map(player.health, player.max_health, player.max_health / 2 + 1, 0, 255 ), 255 ), -- green to yellow
    math.min(utils.map(player.health, player.max_health / 2, 0, 255, 0), 255), -- yellow to red
    0,
    255
  )

  love.graphics.print(player.health .. '%', x+17, y + 6)
  love.graphics.setColor( 255, 255, 255, 255 )

  -- MONEY
  love.graphics.print(player.money, x+60, y + 6)
  love.graphics.draw(self.money, x+50 , y + 4)

  -- WEAPONS
  local currentWeapon = player.inventory:currentWeapon()
  if currentWeapon and not player.doBasicAttack or (player.holdingAmmo and currentWeapon) then
    currentWeapon:drawHud(x + 100, y + 4, true)
  end
  
  --SAVING
  if self.saving then
    self.savingAnimation:draw(self.savingImage, x + 120, y + 6)
  end

  --ACTIVE POTION & CONSUMABLE EFFECTS
  love.graphics.setColor( 255, 255, 255, 255 )
  
  local iconX, iconY = x + 4, y + 20
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

  if player.quest ~= nil then
    local qParent = player.questParent
    print(qParent)
    local questIcon = love.graphics.newImage('images/hud/quest' .. player.questParent .. '.png')
    self.quest = true
    love.graphics.draw(questIcon,iconX + 20*icons, iconY+(iconline*19))
    icons = icons + 1
  end

  --TODO: add slide damage
  

  fonts.revert()
end

return HUD
