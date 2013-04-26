local Timer = require 'vendor/timer'

return{
    name = "Blue Potion",
    image = "blue_potion",
    type = "consumable",
    MAX_ITEMS = 10,
    use = function( consumable, player )
        player.jumpFactor = 1.5
        Timer.add(5, function() 
            player.jumpFactor = 1
        end)
	end
}
