-----------------------------------------------
-- mallet.lua
-- Represents a that a player can wield or pick up
-- Created by NimbusBP1729
-----------------------------------------------

--
-- Creates a new mallet object
-- @return the mallet object created
return{
    hand_x = 5,
    hand_y = 16,
    frameAmt = 3,
    width = 30,
    height = 40,
    damage = 4,
    bbox_width = 16,
    bbox_height = 16,
    bbox_offset_x = 6,
    bbox_offset_y = 16,
    hitAudioClip = 'mallet_hit',
    animations = {
        default = {'once', {'1,1'}, 1},
        wield = {'once', {'1,1','2,1','3,1','2,1'},0.09},
    },
}
