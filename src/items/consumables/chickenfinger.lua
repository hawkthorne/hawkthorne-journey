-- made by Nicko21
return{
    name = "chickenfinger",
    description = "Chicken Finger",
    type = "consumable",
    MAX_ITEMS = 1,
    regen = 5,
    duration = 10,
    use = function( consumable, player )
        local Timer = require('vendor/timer')
        local sound = require('vendor/TEsound')
            player.health = player.max_health
        local orig = player.invulnerable
        player.invulnerable = true
        Timer.add(consumable.props.duration, function() 
            player.invulnerable = orig
        end)
    end
}
