return{
  name = "watermelon",
  description = "Watermelon",
  type = "consumable",
  MAX_ITEMS = 50,
  use = function( consumable, player )
    player.health = (player.health + player.max_health)*0.5
  end
}
