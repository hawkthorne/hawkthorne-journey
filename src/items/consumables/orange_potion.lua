-- made by Nicko21
local Timer = require 'vendor/timer'
return{
  name = "orange_potion",
  description = "Speed Boost Potion",
  type = "consumable",
  MAX_ITEMS = 2,
  consumable = {
    buff = {
      attribute = "speedFactor",
      value = 1.5,
      duration = 10,
      startMessage = "speed boosted by ",
      startMessageValue = true,
      endMessage = "speed boost expired",
    },
  },
}
