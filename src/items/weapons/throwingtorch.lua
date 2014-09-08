-----------------------------------------------
-- throwing.lua
-- The code for the a throwing torch, when it is in the player's inventory.
-----------------------------------------------

return{
  name = 'throwingtorch',
  description = 'Throwing Torch',
  type = 'weapon',
  subtype = "projectile",
  damage = '2',
  special_damage = 'fire= 1',
  info = 'a torch etched with "property of the blacksmith"',
  MAX_ITEMS = 3,
  directory = "weapons/",
}
