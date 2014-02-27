-- playerEffects.lua

local PlayerEffects = {}

local VALID_EFFECTS = {
  ['heal']=1,['hurt']=2,['jump']=3,['run']=4,['attack']=5,
}

function PlayerEffects.heal(player, value)
  if value == 'max' then value = player.max_health end
  local healval = math.min(player.max_health - player.health, value)
  player.health = player.health + healval
  return "healed for " .. healval
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
