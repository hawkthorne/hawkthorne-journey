-- made by Nicko21
return{
  name = "pink_potion",
  description = "Max Health Potion",
  type = "consumable",
  MAX_ITEMS = 2,
  use = function(consumable, player)
    player:potionFlash(1,{255,169,169,255})
    player.health = player.max_health
  end
}
