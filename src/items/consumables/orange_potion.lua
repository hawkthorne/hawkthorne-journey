local Timer = require 'vendor/timer'
return{
    name = "Orange Potion",
    image = "orange_potion",
    type = "consumable",
    MAX_ITEMS = 2,
    use = function( consumable, player )
        local orig = player.speedFactor
    	player.speedFactor = 1.5
        Timer.add(10, function() 
            player.speedFactor = orig
        end)
	end
}
