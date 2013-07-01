-- made by Nicko21
return{
    name = "Health Potion",
    image = "red_potion",
    type = "consumable",
    MAX_ITEMS = 2,
    regen = 5,
    use = function( consumable, player )
		player:beginFlash(1, {255,0,0,255})
    	if (player.health + consumable.props.regen) >= player.max_health then
    		player.health = player.max_health
    	else
    		player.health = player.health + consumable.props.regen
    	end
	end
}
