-----------------------------------------------
-- axe.lua
-- Represents a axe that a player can wield or pick up
-- Created by Nicko21
-----------------------------------------------

--
-- Creates a new sword object
-- @return the sword object created
return{
    hand_x = 24,
    hand_y = 30,
    frameAmt = 3,
    width = 19,
    height = 24,
    damage = 4,
    dead = false,
    unuseAudioClip = 'sword_sheathed',
    hitAudioClip = 'sword_hit',
    swingAudioClip = 'sword_air',
    animations = {
        default = {'once', {'1,1'}, 1},
        wield = {'once', {'1,1','2,1','3,1'},0.09},
    }
}