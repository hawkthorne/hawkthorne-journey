return {
    name = 'jewel',
    width = 10,
    height = 13,
    value = 1000,
    frames = '1-2,1',
    speed = 0.3,
    onPickup = function( player, value )
        player.money = player.money + value
    end
}
