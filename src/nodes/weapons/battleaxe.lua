-----------------------------------------------
-- battleaxe.lua
-- Represents a battleaxe that a player can wield or pick up
-- Created by NimbusBP1729
-----------------------------------------------

--
-- Creates a new battleaxe object
-- @return the battleaxe object created
return {
  hand_x = 9,
  hand_y = 40,
  frameAmt = 3,
  width = 50,
  height = 35,
  dropWidth = 23,
  dropHeight = 44,
  damage = 6,
  special_damage = {slash = 2, axe = 2},
  bbox_width = 22,
  bbox_height = 25,
  bbox_offset_x = {3,28},
  bbox_offset_y = {1,25},
  hitAudioClip = 'mace_hit',
  animations = {
    default = {'once', {'1,1'}, 1},
    wield = {'once', {'2,1','3,1'},0.22}
  },
  action = "wieldaction2"
}
