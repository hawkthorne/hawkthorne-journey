return{
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
}