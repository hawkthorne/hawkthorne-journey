return{
    name = "baggle",
    type = "consumable",
    MAX_ITEMS = 10,
    use = function( consumable, player )
    	player.health = player.max_health
	end
}
