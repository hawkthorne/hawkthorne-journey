-----------------------------------------------
-- club.lua
-- Represents a club that a player can wield or pick up
-----------------------------------------------

--
-- Creates a new club object
-- @return the club object created
return{
    hand_x = 24,
    hand_y = 30,
    frameAmt = 3,
    width = 50,
    height = 40,
    damage = 2,
    dead = false,
    bbox_width = 30,
    bbox_height = 28,
    bbox_offset_x = {21,21,21},
    bbox_offset_y = {3,3,3},
    unuseAudioClip = 'sword_sheathed',
    hitAudioClip = 'punch',
    swingAudioClip = 'sword_air',
    animations = {
        default = {'once', {'1,1'}, 1},
        wield = {'once', {'1,1','2,1','3,1'},0.11},
    }
}
