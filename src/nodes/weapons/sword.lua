-----------------------------------------------
-- sword.lua
-- Represents a sword that a player can wield or pick up
-- Created by NimbusBP1729
-----------------------------------------------

--
-- Creates a new sword object
-- @return the sword object created
return{
    hand_x = 24,
    hand_y = 30,
    frameAmt = 3,
    width = 50,
    height = 40,
    damage = 4,
    dead = false,
    bbox_width = 28,
    bbox_height = 7,
    bbox_offset_x = 21,
    bbox_offset_y = 28,
    unuseAudioClip = 'sword_sheathed',
    hitAudioClip = 'sword_hit',
    swingAudioClip = 'sword_air',
    animations = {
        default = {'once', {'1,1'}, 1},
        wield = {'once', {'1,1','2,1','3,1'},0.09},
    }
}
