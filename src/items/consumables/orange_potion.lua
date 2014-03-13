-- made by Nicko21
local Timer = require 'vendor/timer'
return{
  name = "orange_potion",
  description = "Speed Boost Potion",
  type = "consumable",
  MAX_ITEMS = 2,
  duration = 10;
  use = function( consumable, player )
    player:potionFlash(consumable.props.duration,{255,127,39,255})
    local orig = player.speedFactor
    player.speedFactor = 1.5
    Timer.add(consumable.props.duration, function() 
      player.speedFactor = orig
    end)
  end
}
