-- made by Nicko21
local Timer = require 'vendor/timer'
return{
    name = "keynana",
    description = "Gummy Key-nana",
    type = "consumable",
    MAX_ITEMS = 2,
    duration = 10,
    use = function( consumable, player )
        local orig = player.invulnerable
        player.invulnerable = true
        Timer.add(consumable.props.duration, function() 
            player.invulnerable = orig
        end)
    end
}
