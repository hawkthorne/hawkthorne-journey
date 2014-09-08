return {
  hand_x = 20,
  hand_y = 14,
  frameAmt = 3,
  width = 69,
  height = 27,
  dropWidth = 7,
  dropHeight = 27,
  projectile = "arrow",
  throwDelay = 0.24,
  bbox_width = 7,       -- these handle the bow when it is not being held by the player (on the ground)
  bbox_height = 27,     -- }
  bbox_offset_x = {16}, -- }
  bbox_offset_y = {0},  -- }
  animations = {
    default = {'once', {'1,1'}, 1},
    wield = {'once', {'1,1','1,1','2,1','3,1'},0.12}
  },
  action = "shootarrow",
  actionwalk = "shootarrowwalk",
  actionjump = "shootarrowjump"
}
