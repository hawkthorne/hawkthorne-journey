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
    height = 35,
    damage = 7,
    bbox_width = 22,
    bbox_height = 30,
    bbox_offset_x = {0,3,28},
    bbox_offset_y = {0,1,28},
    hitAudioClip = 'mace_hit',
    animations = {
        default = {'once', {'1,1'}, 1},
        wield = {'once', {'1,1','2,1','3,1'},0.2}
    },
    action = "wieldaction3"
    
}
