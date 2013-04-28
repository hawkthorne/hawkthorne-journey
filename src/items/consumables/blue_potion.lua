-- made by Nicko21
local Timer = require 'vendor/timer'
return{
    name = "Blue Potion",
    image = "blue_potion",
    type = "consumable",
    MAX_ITEMS = 2,
    use = function( consumable, player )
        local orig = player.jumpFactor
        player.jumpFactor = 1.5
        Timer.add(10, function() 
            player.jumpFactor = orig
        end)
	end
}
