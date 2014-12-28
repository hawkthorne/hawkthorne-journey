-----------------------------------------------
-- dagger.lua
-- Represents a dagger that a player can wield or pick up
-- Created by NimbusBP1729
-----------------------------------------------

--
-- Creates a new dagger object
-- @return the dagger object created
return{
  hand_x = 8,
  hand_y = 23,
  frameAmt = 3,
  width = 28,
  height = 31,
  dropWidth = 16,
  dropHeight = 24,
  damage = 2,
  special_damage = {stab = 1},
  dead = false,
  bbox_width = 16,
  bbox_height = 16,
  bbox_offset_x = {0,8,13},
  bbox_offset_y = {0,6,15},
  unuseAudioClip = 'sword_sheathed',
  hitAudioClip = 'sword_hit',
  swingAudioClip = 'sword_air',
  animations = {
    default = {'once', {'1,1'}, 1},
    wield = {'once', {'1,1','2,1','3,1'},0.08},
  }
}
