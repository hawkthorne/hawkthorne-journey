-- made by Nicko21
local Timer = require 'vendor/timer'
return{
    name = "Green Potion",
    image = "green_potion",
    type = "consumable",
    MAX_ITEMS = 2,
    use = function( consumable, player )
        local orig = player.invulnerable
        player.invulnerable = true
        Timer.add(3, function() 
            player.invulnerable = orig
        end)
	end
}
