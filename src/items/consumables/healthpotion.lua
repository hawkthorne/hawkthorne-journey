return{
    name = "healthpotion",
    type = "consumable",
    MAX_ITEMS = 10,
    regen = 5,
    use = function( consumable, player )
    	if (player.health + consumable.props.regen) >= player.max_health then
    		player.health = player.max_health
    	else
    		player.health = player.health + consumable.props.regen
    	end
	end
}
