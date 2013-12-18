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
    MAX_ITEMS = 10,
    quantity = 5,
    directory = 'weapons/',
}