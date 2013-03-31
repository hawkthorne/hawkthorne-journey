return {
    name = 'exp',
    width = 8,
    height = 9,
    value = 1,
    frames = '1-2,1',
    speed = 0.3,
    onPickup = function( player, value )
    	local nextlevelexp = player:getExpToNextLevel(player.exp)
        player.exp = player.exp + value
        if player.exp >= nextlevelexp then
        	player:levelUp()
        end
    end
}
