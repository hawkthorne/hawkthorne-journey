-- made by Nicko21
local Timer = require 'vendor/timer'
return{
    name = "black_potion",
    description = "Dud Potion",
    type = "consumable",
    MAX_ITEMS = 2,
    duration = 10,
    use = function( consumable, player )
        local rand = math.random(5)
        if rand == 1 or rand == 2 then
            --lose half health
            local half = math.floor(player.health/2)
            player:hurt(half)
        elseif rand == 3 then
            --max health
            player.health = player.max_health
        elseif rand == 4 then
            --no jump
            local orig = player.jumpFactor
            player.jumpFactor = 0
            Timer.add(consumable.props.duration, function() 
                player.jumpFactor = orig
            end)
        else
            --no move
            local orig = player.speedFactor
            player.speedFactor = 0
            Timer.add(consumable.props.duration, function() 
                player.speedFactor = orig
            end)
        end
	end
}
