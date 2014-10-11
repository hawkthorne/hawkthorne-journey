-----------------------------------------------
-- axe.lua
-- Represents a axe that a player can wield or pick up
-- Created by NimbusBP1729
-----------------------------------------------

--
-- Creates a new axe object
-- @return the axe object created

return {
  hand_x = 4,
  hand_y = 21,
  frameAmt = 3,
  width = 23,
  height = 23,
  dropWidth = 24,
  dropHeight = 24,
  damage = 4,
  special_damage = {slash = 1, axe = 1},
  bbox_width = 20,
  bbox_height = 20,
  bbox_offset_x = {0,9,8},
  bbox_offset_y = {0,9,16},
  hitAudioClip = 'mace_hit',
  animations = {
    default = {'once', {'1,1'}, 1},
    wield = {'once', {'1,1','2,1','3,1'},0.09},
  },
  --action = "wieldaction3"
}