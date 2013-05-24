return{
    name = "watermelon",
    type = "consumable",
    MAX_ITEMS = 10,
    use = function( consumable, player )
    	player.health = (player.health + player.max_health)*0.5
	end
}
