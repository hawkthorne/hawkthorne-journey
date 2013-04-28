local Timer = require 'vendor/timer'
return{
    name = "Purple Potion",
    image = "purple_potion",
    type = "consumable",
    MAX_ITEMS = 2,
    use = function( consumable, player )
        local orig = player.punchDamage
        player.punchDamage = 5
        Timer.add(30, function() 
            player.punchDamage = orig
        end)
	end
}
