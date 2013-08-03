-- made by Nicko21
return{
    name = "white_potion",
    description = "Greater Health Potion",
    type = "consumable",
    MAX_ITEMS = 2,
    regen = 10,
    use = function( consumable, player )
        if (player.health + consumable.props.regen) >= player.max_health then
            player.health = player.max_health
        else
            player.health = player.health + consumable.props.regen
        end
    end
}
