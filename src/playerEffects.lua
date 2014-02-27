-- playerEffects.lua

local Timer = require 'vendor/timer'


local PlayerEffects = {}

local VALID_EFFECTS = {
  ['heal']=1,['jump']=2,['speed']=3,['attack']=4,
}

function PlayerEffects.heal(player, value)
  if value == 'max' then value = player.max_health end
  local healval = math.min(player.max_health - player.health, value)
  player.health = player.health + healval
  return "healed for " .. healval
end

function PlayerEffects.jump(player, value)
  local orig = player.jumpFactor
  player.jumpFactor = value.jumpFactor
  Timer.add(value.duration, function() 
    player.jumpFactor = orig
    table.insert(player.activeEffects,"jump boost expired")
  end)
  return "jump boosted by " .. value.jumpFactor .. "x"
end

function PlayerEffects.speed(player, value)


end

function PlayerEffects.EFFECT(player, value)
end

function PlayerEffects:doEffect(effects, player)
  for effect,value in pairs(effects) do
    if VALID_EFFECTS[effect] then
      local message = self[effect](player, value)
      if player.activeEffects then
        table.insert(player.activeEffects,message)
      else
        player.activeEffects = {message}
      end
    end
  end
end

return PlayerEffects
