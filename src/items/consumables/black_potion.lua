local Timer = require 'vendor/timer'
return{
    name = "Black Potion",
    image = "black_potion",
    type = "consumable",
    MAX_ITEMS = 2,
    use = function( consumable, player )
        local rand = math.random(5)
        if rand == 1 or rand == 2 then
            --lose half health
            local half = math.floor(player.health/2)
            player.health = player.health - half
        elseif rand == 3 then
            --max health
            player.health = player.max_health
        elseif rand == 4 then
            --no jump
            local orig = player.jumpFactor
            player.jumpFactor = 0
            Timer.add(10, function() 
                player.jumpFactor = orig
            end)
        else
            --no move
            local orig = player.speedFactor
            player.speedFactor = 0
            Timer.add(10, function() 
                player.speedFactor = orig
            end)
        end
	end
}
