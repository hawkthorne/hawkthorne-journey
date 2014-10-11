return {
  name = 'coin',
  width = 8,
  height = 9,
  value = 1,
  frames = '1-2,1',
  speed = 0.3,
  onPickup = function( player, value )
    player.money = player.money + value
  end
}
