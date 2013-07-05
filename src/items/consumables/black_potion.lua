-- made by Nicko21
local Timer = require 'vendor/timer'
return{
    name = "Dud Potion",
    image = "black_potion",
    type = "consumable",
    MAX_ITEMS = 2,
    duration = 10,
    use = function( consumable, player )
        local rand = math.random(5)
        if rand == 1 or rand == 2 then
            --lose half health
            local half = math.floor(player.health/2)
            player:hurt(half)
            player:beginFlash(0.25, {0,0,0,255})
        elseif rand == 3 then
            --max health
            player.health = player.max_health
            player:beginFlash(0.25, {0,0,0,255})
        elseif rand == 4 then
            --no jump
            local orig = player.jumpFactor
            player.jumpFactor = 0
            player:beginFlash(consumable.props.duration, {0,0,0,255})
            Timer.add(consumable.props.duration, function() 
                player.jumpFactor = orig
            end)
        else
            --no move
            local orig = player.speedFactor
            player.speedFactor = 0
            player:beginFlash(consumable.props.duration, {0,0,0,255})
            Timer.add(consumable.props.duration, function() 
                player.speedFactor = orig
            end)
        end
	end
}
