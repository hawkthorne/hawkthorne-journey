-- made by Nicko21
return{
    name = "Yellow Potion",
    image = "yellow_potion",
    type = "consumable",
    MAX_ITEMS = 2,
    use = function( consumable, player )
    	player.money = player.money + 25
	end
}
