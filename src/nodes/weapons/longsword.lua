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
  dropWidth = 11,
  dropHeight = 45,
  damage = 3,
  special_damage = {slash = 2},
  bbox_width = 30,
  bbox_height = 30,
  bbox_offset_x = {2,20},
  bbox_offset_y = {1,24},
  hitAudioClip = 'sword_hit',
  swingAudioClip = 'sword_air',
  animations = {
    default = {'once', {'1,1'}, 1},
    wield = {'once', {'2,1','3,1'}, 0.2}
  },
  action = "wieldaction4"
}
