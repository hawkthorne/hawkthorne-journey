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
    frameAmt = 8,
    width = 48,
    height = 48,
    damage = 4,
    bbox_width = 30,
    bbox_height = 33,
    bbox_offset_x = {6,12,12,12} ,
    bbox_offset_y = {17,17,17,17},
    swingAudioClip = 'fire_thrown',
    isFlammable = true,
    animations = {
        default = {'loop', {'1-6,1'}, 0.09},
        wield = {'once', {'7,1','8,1','7,1','8,1'},0.09},
    },
}
