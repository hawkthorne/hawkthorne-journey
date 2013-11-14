-----------------------------------------------
-- blueskyspecial.lua
-- Represents a blueskyspecial that a player can wield or pick up
-- Created by NimbusBP1729
-----------------------------------------------

--
-- Creates a new blueskyspecial object
-- @return the blueskyspecial object created
return {
    hand_x = 9,
    hand_y = 40,
    frameAmt = 3,
    width = 50,
    height = 35,
    dropWidth = 24,
    dropHeight = 44,
    damage = 10,
    special_damage = {blunt = 2, stab = 2, slash = 2, axe = 2, ice = 2, dismantle = 2, fire = 2},
    bbox_width = 22,
    bbox_height = 30,
    bbox_offset_x = {0,3,28},
    bbox_offset_y = {0,1,28},
    animations = {
        default = {'once', {'1,1'}, 1},
        wield = {'once', {'1,1','2,1','3,1'},0.2}
    },
    action = "wieldaction3"
    
}
