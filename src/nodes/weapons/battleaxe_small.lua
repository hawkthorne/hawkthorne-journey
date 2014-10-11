-----------------------------------------------
-- battleaxe_small.lua
-- Represents a battleaxe that a player can wield or pick up
-- Created by NimbusBP1729
-----------------------------------------------

--
-- Creates a new small battleaxe object
-- @return the small battleaxe object created
return {
  hand_x = 12,
  hand_y = 20,
  frameAmt = 3,
  width = 32,
  height = 31,
  dropWidth = 23,
  dropHeight = 21,
  damage = 4,
  special_damage = {slash = 1, axe = 1},
  bbox_width = 22,
  bbox_height = 22,
  bbox_offset_x = {1,9,10},
  bbox_offset_y = {0,0,10},
  hitAudioClip = 'mace_hit',
  animations = {
    default = {'once', {'1,1'}, 1},
    wield = {'once', {'1,1','2,1','3,1'},0.1}
  },
  action = "wieldaction2"
}
