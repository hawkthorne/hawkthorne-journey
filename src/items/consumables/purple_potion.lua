-- made by Nicko21
local Timer = require 'vendor/timer'
return{
  name = "purple_potion",
  description = "Punch Damage Potion",
  type = "consumable",
  MAX_ITEMS = 2,
  use = function( consumable, player )
    local orig = player.punchDamage
    local duration = 30;
    player.punchDamage = 5
    player:potionFlash(duration,{98,44,99,255})
    Timer.add(duration, function() 
      player.punchDamage = orig
    end)
  end
}
