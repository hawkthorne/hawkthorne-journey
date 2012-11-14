-----------------------------------------------
-- sword.lua
-- Represents a sword that a player can wield or pick up
-- Created by NimbusBP1729
-----------------------------------------------

--
-- Creates a new sword object
-- @return the sword object created
return{
    torch.hand_x = 1,
    torch.hand_y = 41,
    rowAmt = 1,
    colAmt = 8,
    torch.frameWidth = 24,
    torch.frameHeight = 48,
    torch.width = 48,
    torch.height = torch.frameHeight,
    torch.sheet = love.graphics.newImage('images/torch_action.png'),
    torch.burn_rate = 0.09,
    torch.damage = 4,
    torch.swingAudioClip = 'fire_thrown'
    animations = {
        default = {'loop', {'1-6,1'}, 0.09},
        wield = {'once', {'7,1','8,1','7,1','8,1'},0.09},
    },
}
