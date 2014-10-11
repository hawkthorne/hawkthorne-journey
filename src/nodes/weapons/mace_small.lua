-----------------------------------------------
-- mace.lua
-- Represents a small mace that a player can wield or pick up
-- Created by NimbusBP1729
-----------------------------------------------

--
-- Creates a new small mace object
-- @return the small mace object created
return {
  hand_x = 8,
  hand_y = 22,
  frameAmt = 3,
  width = 29,
  height = 28,
  dropWidth = 24,
  dropHeight = 28,
  damage = 4,
  special_damage = {blunt = 1},
  bbox_width = 20,
  bbox_height = 20,
  bbox_offset_x = {0,6,9},
  bbox_offset_y = {0,3,11},
  hitAudioClip = 'mace_hit',
  animations = {
    default = {'once', {'1,1'}, 1},
    wield = {'once', {'1,1','2,1','3,1'},0.17}
  },
  action = "wieldaction3"
}
