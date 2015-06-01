-----------------------------------------------
-- throwingKnifeItem.lua
-- The code for the icicle, when it is in the players inventory.
-----------------------------------------------
local Projectile = require 'nodes/projectile'
local GS = require 'vendor/gamestate'
return{
  name = "benzalkFire",
  description = "Benzalk Fire",
  type = "weapon",
  subtype = "projectile",
  damage = '2',
  special_damage = 'fire= 10',
  info = 'fire',
  MAX_ITEMS = 10,
  quantity = 5,
  directory = 'weapons/',
}