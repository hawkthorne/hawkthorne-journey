return {
    name = 'life',
    width = 13,
    height = 9,
    value = 1,
    frames = '1-2,1',
    speed = 0.3,
    onPickup = function( player, value )
        player.lives = player.lives + 1
    end
}
