-----------------------------------------------
-- axe.lua
-- Represents a axe that a player can wield or pick up
-- Created by Nicko21
-----------------------------------------------

--
-- Creates a new axe object
-- @return the axe object created
return {
    hand_x = 24,
    hand_y = 30,
    frameAmt = 3,
    width = 23,
    height = 23,
    damage = 4,
    bbox_width = 23,
    bbox_height = 23,
    bbox_offset_x = {24,21,21},
    bbox_offset_y = {29,27,27},
    hitAudioClip = 'axe_hit',
    animations = {
        default = {'once', {'1,1'}, 1},
        wield = {'once', {'1,1','2,1','3,1'},0.09},
    }
}
