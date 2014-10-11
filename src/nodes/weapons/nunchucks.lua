-----------------------------------------------
-- sword.lua
-- Represents a sword that a player can wield or pick up
-- Created by NimbusBP1729
-----------------------------------------------

--
-- Creates a new sword object
-- @return the sword object created
return{
  hand_x = 22,
  hand_y = 28,
  frameAmt = 3,
  width = 50,
  height = 40,
  dropWidth = 10,
  dropHeight = 34,
  damage = 2,
  special_damage = {blunt = 1},
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