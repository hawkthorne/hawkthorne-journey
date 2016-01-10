local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'
local utils = require 'utils'
local Timer = require 'vendor/timer'
local anim8 = require 'vendor/anim8'

local HUD = {}
HUD.__index = HUD

local lens = love.graphics.newImage('images/hud/lens.png')
local chevron = love.graphics.newImage('images/hud/chevron.png')
local energy = love.graphics.newImage('images/hud/energy.png')
local savingImage = love.graphics.newImage('images/hud/saving.png')

lens:setFilter('nearest', 'nearest')
chevron:setFilter('nearest', 'nearest')
energy:setFilter('nearest', 'nearest')
savingImage:setFilter('nearest', 'nearest')

function HUD.new(level)
  local hud = {}
  setmetatable(hud, HUD)

  local character = level.player.character

  hud.sheet = level.player.character:sheet()
  hud.character_quad = love.graphics.newQuad(0, character.offset or 5, 48, 34, hud.sheet:getWidth(), hud.sheet:getHeight())

  hud.character_stencil = function( x, y )
    love.graphics.circle( 'fill', x + 31, y + 31, 21 )
  end

  hud.energy_stencil = function( x, y )
    love.graphics.rectangle( 'fill', x + 50, y + 27, 59, 9 )
  end

    hud.saving = false

    local h = anim8.newGrid(36, 36, savingImage:getWidth(), savingImage:getHeight())
    hud.savingAnimation = anim8.newAnimation('loop', h('1-8,1'), .25)
    hud.savingAnimation:pause()

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
end

function HUD:draw( player )
  if not window.dressing_visible then
    return
  end

  self.sheet = player.character:sheet()

  fonts.set( 'big' )

  self.x, self.y = camera.x + 10, camera.y + 10

  love.graphics.setColor( 255, 255, 255, 255 )
  love.graphics.draw( chevron, self.x, self.y)
  --love.graphics.stencil(function() self.energy_stencil(self.x, self.y) end)--doesn't pass arguments so is essentially useless
  love.graphics.setColor(
    math.min(utils.map(player.health, player.max_health, player.max_health / 2 + 1, 0, 255 ), 255 ), -- green to yellow
    math.min(utils.map(player.health, player.max_health / 2, 0, 255, 0), 255), -- yellow to red
    0,
    255
  )
  --HEALTH
  
  local energy_quad = love.graphics.newQuad(50 + (player.max_health - player.health) * .56, 0, 59, 60, energy:getWidth(), energy:getHeight())

  love.graphics.draw(energy, energy_quad, self.x + 50, self.y)

  love.graphics.setColor(255, 255, 255, 255)

  local currentWeapon = player.inventory:currentWeapon()
  if currentWeapon and not player.doBasicAttack or (player.holdingAmmo and currentWeapon) then
    local position = {x = self.x + 22, y = self.y + 22}
    currentWeapon:draw(position, nil,false)
  else
    love.graphics.draw(self.sheet, self.character_quad, self.x + 7, self.y + 17)
  end
  love.graphics.draw(lens, self.x, self.y)
  love.graphics.setColor( 0, 0, 0, 255 )
  love.graphics.print(player.money, self.x + 69, self.y + 41,0,0.5,0.5)
  love.graphics.print(player.character.name, self.x + 60, self.y + 15,0,0.5,0.5)
  if player.activeEffects then
    love.graphics.setColor( 0, 0, 0, 255 )
    for i,effect in ipairs(player.activeEffects) do
      love.graphics.printf(effect, self.x + 20, self.y + 40 + (20 * i), 350, "left",0,0.5,0.5)
    end
  end

  love.graphics.setColor( 255, 255, 255, 255 )

  if self.saving then
    self.savingAnimation:draw(savingImage, self.x + camera:getWidth() - 60, self.y)
  end

  fonts.revert()
end

return HUD
