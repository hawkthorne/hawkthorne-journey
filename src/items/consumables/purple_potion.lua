-- made by Nicko21
local Timer = require 'vendor/timer'
return{
    name = "purple_potion",
    description = "Punch Damage Potion",
    type = "consumable",
    MAX_ITEMS = 2,
    duration = 30;
    use = function( consumable, player )
        local orig = player.punchDamage
        player.punchDamage = 5
        Timer.add(consumable.props.duration, function() 
            player.punchDamage = orig
        end)
    end
}
