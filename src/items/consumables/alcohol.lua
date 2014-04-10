-- made by Nicko21
local Timer = require 'vendor/timer'
return{
  name = "alcohol",
  description = "Alcohol",
  type = "consumable",

  MAX_ITEMS = 10,
  duration = 40,
  use = function( consumable, player )
    local orig_jump = player.jumpFactor
    local orig_speed = player.speedFactor
    local orig_punch = player.punchDamage

    --player:potionFlash(consumable.props.duration,{29,50,20,255})

    Timer.add(10, function() 
      player.jumpFactor = math.random(0.00, 1.50)
      player.punchDamage = math.random(0, 5)
      player.speedFactor = math.random(0.1, 1.5)
    end)
    Timer.add(10, function() 
      player.jumpFactor = math.random(0.00, 1.50)
      player.punchDamage = math.random(0, 5)
      player.speedFactor = math.random(0.1, 1.5)
    end)
    Timer.add(10, function() 
      player.jumpFactor = math.random(0.00, 1.50)
      player.punchDamage = math.random(0, 5)
      player.speedFactor = math.random(0.1, 1.5)
    end)
    Timer.add(10, function() 
      player.jumpFactor = math.random(0.00, 1.50)
      player.punchDamage = math.random(0, 5)
      player.speedFactor = math.random(0.1, 1.5)
    end)
    
    Timer.add(consumable.props.duration, function() 
      player.jumpFactor = orig_jump
      player.speedFactor = orig_speed
      player.punchDamage = orig_punch
    end)
  end
}
