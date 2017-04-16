return {
    name = 'gold',
    width = 21,
    height = 8,
    value = 100,
    frames = '1-4,1',
    speed = 0.3,
    onPickup = function( player, value )
        player.money = player.money + value
    end
}
