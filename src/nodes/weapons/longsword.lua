-----------------------------------------------
-- longsword.lua
-- Represents a longsword that a player can wield or pick up
-----------------------------------------------

--
-- Creates a new longsword object
-- @return the longsword object created
return {
    hand_x = 9,
    hand_y = 40,
    frameAmt = 3,
    width = 30,
    height = 30,
    damage = 3,
    bbox_width = 30,
    bbox_height = 30,
    bbox_offset_x = {4,3,28},
    bbox_offset_y = {0,1,28},
    hitAudioClip = 'sword_hit',
    swingAudioClip = 'sword_air',
    animations = {
        default = {'once', {'1,1'}, 1},
        wield = {'once', {'1,1','2,1','3,1'}, 0.15}
    },
    action = "wieldaction4"
    
}
