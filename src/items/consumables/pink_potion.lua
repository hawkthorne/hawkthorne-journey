-- made by Nicko21
return{
    name = "pink_potion",
    description = "Max Health Potion",
    type = "consumable",
    MAX_ITEMS = 2,
    regen = 5,
    use = function( consumable, player )
            player.health = player.max_health
    end
}
