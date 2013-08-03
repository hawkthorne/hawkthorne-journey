-- made by Nicko21
return{
    name = "yellow_potion",
    description = "Money Potion",
    type = "consumable",
    MAX_ITEMS = 2,
    use = function( consumable, player )
        player.money = player.money + 25
    end
}
