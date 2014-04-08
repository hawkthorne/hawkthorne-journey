return{
  name = "flowers",
  description = "Flowers",
  type = "consumable",
  MAX_ITEMS = 10,
  use = function( consumable, player, npc )
    hilda.affection = hilda.affection + 10
  end
}
