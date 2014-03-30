-- made by Nicko21
local Timer = require 'vendor/timer'
return{
  name = "green_potion",
  description = "Invulnerability Potion",
  type = "consumable",
  MAX_ITEMS = 2,
  duration = 5,
  use = function( consumable, player )
    local orig = player.invulnerable
    player.invulnerable = true
    player:potionFlash(consumable.props.duration,{34,177,76,255})
    Timer.add(consumable.props.duration, function() 
      player.invulnerable = orig
    end)
  end
}
