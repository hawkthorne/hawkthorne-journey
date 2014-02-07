-- made by Nicko21
return{
  name = "yellow_potion",
  description = "Money Potion",
  type = "consumable",
  MAX_ITEMS = 2,
  use = function( consumable, player )
    local rand = math.random(10)
      if rand == 1 then
        player.money = player.money + 700
      elseif rand == 2 then
        player.money = player.money + 200
      elseif rand == 3 then
        player.money = player.money + 100
      elseif rand == 4 or rand == 5 then
        player.money = player.money + 50
      elseif rand == 6 or rand == 7 then
        player.money = player.money + 25
      else
        player.money = player.money + 5
      end
  end
}
