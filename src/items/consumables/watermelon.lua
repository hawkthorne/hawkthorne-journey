return{
<<<<<<< HEAD
    name = "watermelon",
    description = "Watermelon",
    type = "consumable",
    MAX_ITEMS = 10,
    use = function( consumable, player )
        player.health = (player.health + player.max_health)*0.5
    end
=======
  name = "watermelon",
  description = "Watermelon",
  type = "consumable",
  MAX_ITEMS = 50,
  use = function( consumable, player )
    if (player.health + consumable.props.regen) >= player.max_health then
      player.health = player.max_health
    else
      player.health = player.health + consumable.props.regen
    end
  end
>>>>>>> 6374e61ee03d32a225c0edf7813a63a70191cf9f
}
