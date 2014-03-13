-- made by Nicko21
return{
  name = "red_potion",
  description = "Health Potion",
  type = "consumable",
  MAX_ITEMS = 2,
  regen = 25,
  use = function( consumable, player )
    player:potionFlash(1,{164,64,66,255})
    if (player.health + consumable.props.regen) >= player.max_health then
      player.health = player.max_health
    else
      player.health = player.health + consumable.props.regen
    end
  end
}
