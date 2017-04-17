-----------------------------------------------
-- throwingKnifeItem.lua
-- The code for the fireball, when it is in the players inventory.
-----------------------------------------------
local Projectile = require 'nodes/projectile'
local GS = require 'vendor/gamestate'
return{
  name = "fireball",
  description = "FireBall",
  type = "weapon",
  subtype = "projectile",
  damage = '2',
  special_damage = 'fire= 10',
  info = 'a ball of fire',
  MAX_ITEMS = 10,
  quantity = 5,
  directory = 'weapons/',
}