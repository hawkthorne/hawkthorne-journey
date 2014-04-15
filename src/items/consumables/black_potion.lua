-- made by Nicko21
local Timer = require 'vendor/timer'
return{
  name = "black_potion",
  description = "Dud Potion",
  type = "consumable",
  MAX_ITEMS = 2,
  consumable = {
    randEffect = {
      {hurt = "half"},
      {hurt = "half"},
      {heal = "max"},
      {buff = {
        attribute = "jumpFactor",
        value = 0,
        duration = 10,
        startMessage = "jump disabled",
        endMessage = "jump enabled",
      }},
      {buff = {
        attribute = "speedFactor",
        value = 0,
        duration = 10,
        startMessage = "movement disabled",
        endMessage = "movement enabled",
      }},
      randnum = 5,
    }
  }
}
