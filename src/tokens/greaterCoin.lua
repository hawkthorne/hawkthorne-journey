return {
    name = 'greaterCoin',
    width = 13,
    height = 13,
    value = 10,
    frames = '1-2,1',
    speed = 0.3,
    onPickup = function( player, value )
        player.money = player.money + value
    end
}
