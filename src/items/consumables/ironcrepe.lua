-- made by Nicko21
local Timer = require 'vendor/timer'
return{
    name = "ironcrepe",
    description = "Chewy Iron Crepe",
    type = "consumable",
    MAX_ITEMS = 2,
    duration = 35;
    use = function( consumable, player )
        local orig = player.punchDamage
        player.punchDamage = 10
        Timer.add(consumable.props.duration, function() 
            player.punchDamage = orig
        end)
    end
}
