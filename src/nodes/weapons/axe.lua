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
    hand_y = 20,
    frameAmt = 3,
    width = 20,
    height = 20,
    damage = 4,
    bbox_width = 25,
    bbox_height = 25,
    bbox_offset_x = {5,5,5},
    bbox_offset_y = {20,21,6},
    hitAudioClip = 'mace_hit',
    animations = {
        default = {'once', {'1,1'}, 1},
        wield = {'once', {'1,1','2,1','3,1'},0.09},
    }
}
