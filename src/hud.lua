local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'
local utils = require 'utils'
local Timer = require 'vendor/timer'
local anim8 = require 'vendor/anim8'

local HUD = {}
HUD.__index = HUD

local savingImage = love.graphics.newImage('images/hud/saving.png')

savingImage:setFilter('nearest', 'nearest')


function HUD.new(level)
  local hud = {}
  setmetatable(hud, HUD)

  local character = level.player.character
  local owd = character:getOverworld()

  hud.sheet = love.graphics.newImage('images/characters/' .. character.name .. '/overworld.png')
  hud.character_quad = love.graphics.newQuad((owd-1)*36, 0, 36, 36, hud.sheet:getDimensions())

  hud.money = love.graphics.newImage('images/hud/money.png')
  hud.health_full = love.graphics.newImage('images/hud/health_full.png')
  hud.health_empty = love.graphics.newImage('images/hud/health_empty.png')

  hud.money:setFilter('nearest', 'nearest')
  hud.health_full:setFilter('nearest', 'nearest')
  hud.health_empty:setFilter('nearest', 'nearest')

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

-- Draw the quest badge in HUD
-- @param player the player
-- @return nil
function HUD:questBadge( player )
    local quest = player.quest
    local questParent = player.questParent

    local width = (love.graphics.getFont():getWidth( quest ) * 0.5) + 4
    local height = 24
    local margin = 20

    local x = camera.x + 125
    local y = camera.y + 23

    -- Draw rectangle
    love.graphics.setColor( 0, 0, 0, 180 )
    love.graphics.rectangle('fill', x, y, width, height)

    -- Draw text
    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.print(quest, (x + 2), (y + 2), 0, 0.5, 0.5)
    love.graphics.push()
    love.graphics.printf("for " .. questParent, (x + 2), (y + 15), (width + 8), "left", 0, 0.5, 0.5)
    love.graphics.pop()

    love.graphics.setColor( 255, 255, 255, 255 )
end

function HUD:draw( player )
  if not window.dressing_visible then
    return
  end

  fonts.set( 'small' )

  self.x, self.y = camera.x, camera.y
  love.graphics.setColor( 255, 255, 255, 255 )
  
  -- CHARACTER
  love.graphics.draw(self.sheet, self.character_quad, self.x + 17, self.y + 27)
  
  -- MONEY
  love.graphics.print(player.money, self.x + 450, self.y + 35)
  love.graphics.draw(self.money, self.x + 482, self.y + 33)
  
  -- HEALTH 
  local heartValue = player.max_health / 10
  local tracker = 0
  
  for i = 1,2 do
    for j = 1,5 do
      if tracker + heartValue <= player.health then
        love.graphics.draw(self.health_full, self.x + 58 + 13*(j-1), self.y + 35 + 13*(i - 1))
      elseif tracker < player.health then
        love.graphics.draw(self.health_empty, self.x + 58 + 13*(j-1), self.y + 35 + 13*(i - 1))
      end
      tracker = tracker + heartValue
    end
  end

  -- WEAPONS
  local currentWeapon = player.inventory:currentWeapon()
  if currentWeapon and not player.doBasicAttack or (player.holdingAmmo and currentWeapon) then
    local position = {x = self.x + 22, y = self.y + 22}
    currentWeapon:draw(position, nil,false)
  else
  end
  

  --SAVING
  -- love.graphics.setColor( 255, 255, 255, 255 )
  -- if self.saving then
    -- self.savingAnimation:draw(savingImage, self.x + 120 + 5, self.y + 12)
  -- end
  
  --POTION EFFECTS
  -- if player.activeEffects then
    -- love.graphics.setColor( 0, 0, 0, 255 )
    -- for i,effect in ipairs(player.activeEffects) do
      -- love.graphics.printf(effect, self.x + 20, self.y + 40 + (20 * i), 350, "left",0,0.5,0.5)
    -- end
  -- end

  --QUESTS
  -- if player.quest ~= nil then
    -- self:questBadge( player )
  -- end

  fonts.revert()
end

return HUD
