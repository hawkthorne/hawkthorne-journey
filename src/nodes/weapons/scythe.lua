-----------------------------------------------
-- scythe.lua
-- Represents a scythe that a player can wield or pick up
-----------------------------------------------

--
-- Creates a new scythe object
-- @return the scythe object created
return {
  hand_x = 4,
  hand_y = 35,
  frameAmt = 3,
  width = 30,
  height = 61,
  dropWidth = 11,
  dropHeight = 45,
  damage = 2,
  special_damage = {slash = 2},
  bbox_width = 30,
  bbox_height = 30,
  bbox_offset_x = {0,11,16},
  bbox_offset_y = {0,8,27},
  hitAudioClip = 'sword_hit',
  swingAudioClip = 'sword_air',
  animations = {
    default = {'once', {'1,1'}, 1},
    wield = {'once', {'1,1','2,1','3,1'}, 0.2}
  },
  action = "wieldaction4"
}
