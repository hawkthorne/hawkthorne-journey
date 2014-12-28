return{
  hand_x = 24,
  hand_y = 30,
  frameAmt = 3,
  width = 50,
  height = 40,
  dropWidth = 9,
  dropHeight = 33,
  damage = 5,
  special_damage = {stab = 1, slash = 2},
  dead = false,
  bbox_width = 30,
  bbox_height = 28,
  bbox_offset_x = {21,21,21},
  bbox_offset_y = {3,3,3},
  unuseAudioClip = 'sword_sheathed',
  hitAudioClip = 'sword_hit',
  swingAudioClip = 'sword_air',
  animations = {
    default = {'once', {'1,1'}, 1},
    wield = {'once', {'1,1','2,1','3,1'},0.11},
  }
}
