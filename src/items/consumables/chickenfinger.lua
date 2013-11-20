-- made by Nicko21
return{
    name = "chickenfinger",
    description = "Chicken Finger",
    type = "consumable",
    MAX_ITEMS = 2,
    regen = 5,
    duration = 5,
    use = function( consumable, player )
            player.health = player.max_health
            player.invulnerable = true
            Timer.add(consumable.props.duration, function() 
            player.invulnerable = orig
    end
}
