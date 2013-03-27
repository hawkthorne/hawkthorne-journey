-----------------------------------------------
-- axe.lua
-- Represents a axe that a player can wield or pick up
-- Created by Nicko21
-----------------------------------------------

--
-- Creates a new axe object
-- @return the axe object created
return {
    hand_x = 6,
    hand_y = 21,
    frameAmt = 3,
    width = 23,
    height = 23,
    damage = 4,
    bbox_width = 18,
    bbox_height = 23,
    bbox_offset_x = {0,0,1},
    bbox_offset_y = {0,0,1},
    hitAudioClip = 'mace_hit',
    animations = {
        default = {'once', {'1,1'}, 1},
        wield = {'once', {'1,1','2,1','3,1'},0.09},
    }
}
