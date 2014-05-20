-- playerEffects.lua
local Timer = require 'vendor/timer'

local PlayerEffects = {}

local VALID_EFFECTS = {
  ['heal']=1,['buff']=2,['zombie']=3,['money']=4,['hurt']=5,['alcohol']=6
}

local HUDMessage = function(message, player, duration)
  local d = duration or 4
  if not player.activeEffects then
    player.activeEffects = {message}
  else
    table.insert(player.activeEffects, message)
  end
  Timer.add(d, function()
    table.remove(player.activeEffects, 1)
  end)
end

function PlayerEffects.heal(player, value)
  if value == 'max' then value = player.max_health end
  if value < 1 and value > 0 then value = math.floor((player.max_health - player.health)*value) end
  local healval = math.min(player.max_health - player.health, value)
  player.health = player.health + healval
  player:potionFlash(1, {192,192,192,255})
  return healval == 0 and "fully healed" or "healed for " .. healval
end

function PlayerEffects.buff(player, buff)
  local orig = buff.default or player[buff.attribute]
  player[buff.attribute] = buff.value
  Timer.add(buff.duration, function()
    player[buff.attribute] = orig
    HUDMessage(buff.endMessage, player)
  end)
  player:potionFlash(buff.duration, buff.color or {192,192,192,255})
  return buff.startMessage .. (buff.startMessageValue and buff.value or "")
end

function PlayerEffects.money(player, value)
  player.money = player.money + value
  return value .. " coins added"
end

function PlayerEffects.hurt(player, value)
  if value < 1 and value > 0 then value = math.floor(player.health*value) end
  player:hurt(value)
  return "hurt for " .. value .. " damage"
end

function PlayerEffects:randEffect(player, effects)
  local rand = math.random()
  for i,prob in ipairs(effects.p) do
    if rand <= prob  then
      self:doEffect(effects[i], player)
      break
    end
  end
end

function PlayerEffects.zombie(player)
  local punchDamage = player.punchDamage
  local jumpDamage = player.jumpDamage
  local slideDamage = player.slideDamage
  local costume = player.character.costume
  Timer.add(66, function () --Resets damage boost and costume after one minute being active
    HUDMessage("a chilling gust of AC makes you forget your hunger for brains", player, 10)
    player.punchDamage = punchDamage
    player.jumpDamage = jumpDamage
    player.slideDamage = slideDamage
    player.character.costume = costume
  end)
  HUDMessage("that taco meat tastes weird...", player)
  for i=1,2 do
    Timer.add(2*i-1, function () -- Damage over time
      if player.health > 1 then player:hurt(15) end
    end)
  end
  Timer.add(6, function () -- Set costume to zombie and double unarmed player damage.
    if love.filesystem.exists("images/characters/" .. player.character.name .. "/zombie.png") then
      player.character.costume = 'zombie'
    end
    HUDMessage("holy crap, you are a zombie!", player, 10)
    player.jumpDamage = player.jumpDamage * 2
    player.punchDamage = player.punchDamage * 2
    player.slideDamage = player.slideDamage * 2
  end)
end

function PlayerEffects.dudEffect(item, player)
  HUDMessage("that " .. item .. " got stale and lost its power", player, 10)
end

function PlayerEffects.alcohol(player)
  local punchDamage = player.punchDamage
  local jumpFactor = player.jumpFactor
  local speedFactor = player.speedFactor

  Timer.add(40, function () --Resets everything
    HUDMessage("Sobering up", player)
    player.punchDamage = punchDamage
    player.jumpFactor = jumpFactor
    player.speedFactor = speedFactor

  end)

  HUDMessage("I think you drank too much...", player)
  player.jumpFactor = math.random(0.00, 1.50)
  player.punchDamage = math.random(0, 5)
  player.speedFactor = math.random(0.1, 1.5)

  Timer.addPeriodic(10, function()
      player.jumpFactor = math.random(0.00, 1.50)
      player.punchDamage = math.random(0, 5)
      player.speedFactor = math.random(0.1, 1.5)
  end, 3)

end

function PlayerEffects:doEffect(effects, player)
  for effect,value in pairs(effects) do
    if effect == "randEffect" then
      self:randEffect(player, value)
    elseif VALID_EFFECTS[effect] then
      HUDMessage(self[effect](player, value), player)
    else
      error("Invalid player effect type: " .. effect)
    end
  end
end

return PlayerEffects
