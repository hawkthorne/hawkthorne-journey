-----------------------------------------------
-- throwingKnifeItem.lua
-- The code for the icicle, when it is in the players inventory.
-----------------------------------------------
local Projectile = require 'nodes/projectile'
local GS = require 'vendor/gamestate'
return{
  name = "icicle",
  description = "Icicle",
  type = "weapon",
  subtype = "projectile",
  damage = '2',
  special_damage = 'stab= 1, ice=1',
  info = 'a set of 5 very sharp icicles',
  MAX_ITEMS = 99,
  quantity = 5,
  directory = 'weapons/',
}