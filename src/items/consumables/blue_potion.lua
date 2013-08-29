-- made by Nicko21
local Timer = require 'vendor/timer'
return{
    name = "blue_potion",
    description = "Jump Boost Potion",
    type = "consumable",
    MAX_ITEMS = 2,
    duration = 10,
    use = function( consumable, player )
        local orig = player.jumpFactor
        player.jumpFactor = 1.5
        Timer.add(consumable.props.duration, function() 
            player.jumpFactor = orig
        end)
    end
}
