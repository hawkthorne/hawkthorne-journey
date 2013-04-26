local Timer = require 'vendor/timer'
return{
    name = "Black Potion",
    image = "black_potion",
    type = "consumable",
    MAX_ITEMS = 10,
    use = function( consumable, player )
        player.speedFactor = 1.5
    	Timer.add(5, function() 
            player.speedFactor = 1
        end)
	end
}
