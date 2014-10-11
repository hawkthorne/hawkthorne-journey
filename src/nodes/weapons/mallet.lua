-----------------------------------------------
-- mallet.lua
-- Represents a that a player can wield or pick up
-- Created by NimbusBP1729
-----------------------------------------------

--
-- Creates a new mallet object
-- @return the mallet object created
return{
  hand_x = 5,
  hand_y = 16,
  frameAmt = 3,
  width = 30,
  height = 40,
  dropWidth = 11,
  dropHeight = 18,
  damage = 6,
  special_damage = {blunt = 2},
  bbox_width = 15,
  bbox_height = 28,
  bbox_offset_x = {0,4,6,4},
  bbox_offset_y = {0,0,16,0},
  hitAudioClip = 'mallet_hit',
  animations = {
    default = {'once', {'1,1'}, 1},
    wield = {'once', {'1,1','2,1','3,1','2,1'},0.07},
  },
  action = "wieldaction5"
}
