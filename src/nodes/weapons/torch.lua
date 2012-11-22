-----------------------------------------------
-- sword.lua
-- Represents a sword that a player can wield or pick up
-- Created by NimbusBP1729
-----------------------------------------------

--
-- Creates a new sword object
-- @return the sword object created
return{
    hand_x = 1,
    hand_y = 41,
    rowAmt = 1,
    colAmt = 8,
    frameWidth = 24,
    frameHeight = 48,
    width = 48,
    height = 48,
    damage = 4,
    swingAudioClip = 'fire_thrown',
    isFlammable = true,
    animations = {
        default = {'loop', {'1-6,1'}, 0.09},
        wield = {'once', {'7,1','8,1','7,1','8,1'},0.09},
    },
}
