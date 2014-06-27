-- made by Nicko21
local Timer = require 'vendor/timer'
return{
  name = "black_potion",
  description = "Dud Potion",
  type = "consumable",
  MAX_ITEMS = 2,
  consumable = {
    randEffect = {
      p = {0.4,0.6,0.8,1},
      {hurt = 0.5},
      {heal = "max"},
      {buff = {
        attribute = "jumpFactor",
        value = 0,
        default = 1,
        duration = 10,
        startMessage = "jump disabled",
        endMessage = "jump enabled",
      }},
      {buff = {
        attribute = "speedFactor",
        value = 0,
        default = 1,
        duration = 10,
        startMessage = "movement disabled",
        endMessage = "movement enabled",
      }},
    }
  }
}
