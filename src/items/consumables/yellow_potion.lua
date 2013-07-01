-- made by Nicko21
return{
    name = "Money Potion",
    image = "yellow_potion",
    type = "consumable",
    MAX_ITEMS = 2,
    use = function( consumable, player )
		player:beginFlash(1, {255,215,0,255})
    	player.money = player.money + 25
	end
}
