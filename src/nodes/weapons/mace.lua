-----------------------------------------------
-- mace.lua
-- Represents a mace that a player can wield or pick up
-- Created by NimbusBP1729
-----------------------------------------------

--
-- Creates a new mace object
-- @return the mace object created
return {
    hand_x = 9,
    hand_y = 40,
    frameAmt = 3,
    width = 50,
    height = 50,
    damage = 4,
    hitAudioClip = 'mace_hit',
    animations = {
        default = {'once', {'1,1'}, 1},
        wield = {'once', {'1,1','2,1','3,1'},0.09}
    }
}