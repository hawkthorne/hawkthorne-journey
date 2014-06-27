-----------------------------------------------
-- torch.lua
-- Represen a torch that a player can wield or pick up
-- Created by NimbusBP1729
-----------------------------------------------

--
-- Creates a new torch object
-- @return the torch object created
return{
    hand_x = 1,
    hand_y = 41,
    frameAmt = 8,
    width = 48,
    height = 48,
    dropWidth = 24,
    dropHeight = 40,
    damage = 2,
    special_damage = {fire = 3},
    bbox_width = 20,
    bbox_height = 33,
    bbox_offset_x = {3,12,12,12} ,
    bbox_offset_y = {17,17,17,17},
    swingAudioClip = 'fire_thrown',
    isFlammable = true,
    animations = {
        default = {'loop', {'1-6,1'}, 0.09},
        wield = {'once', {'7,1','8,1','7,1','8,1'},0.11},
    },
}
