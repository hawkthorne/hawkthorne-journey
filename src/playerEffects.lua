-- playerEffects.lua

local Timer = require 'vendor/timer'


local PlayerEffects = {}

local VALID_EFFECTS = {
  ['heal']=1,['jump']=2,['speed']=3,['attack']=4,
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
  if value == 'half' then value = math.floor((player.max_health - player.health)*0.5) end
  local healval = math.min(player.max_health - player.health, value)
  player.health = player.health + healval
  return "healed for " .. healval
end

function PlayerEffects.jump(player, value)
  local orig = player.jumpFactor
  player.jumpFactor = value.jumpFactor
  Timer.add(value.duration, function() 
    player.jumpFactor = orig
    HUDMessage("jump boost expired", player)
  end)
  return "jump boosted by " .. value.jumpFactor .. "x"
end

function PlayerEffects.speed(player, value)
  local orig = player.speedFactor
  player.speedFactor = value.speedFactor
  Timer.add(value.duration, function() 
    player.speedFactor = orig
    HUDMessage("speed boost expired", player)
  end)
end

function PlayerEffects:doEffect(effects, player)
  for effect,value in pairs(effects) do
    if VALID_EFFECTS[effect] then
      HUDMessage(self[effect](player, value), player)
    else
      error("Invalid player effect type: " .. effect)
    end
  end
end

return PlayerEffects
