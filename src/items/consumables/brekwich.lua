-- made by Nicko21
local Timer = require 'vendor/timer'
return{
  name = "brekwich",
  description = "Brekwich",
  type = "consumable",
  info = "a tasty breakfast sandwitch that will put some pep in your step",
  MAX_ITEMS = 2,
  width = 24,
  consumable = {
    buff = {
      attribute = "jumpFactor",
      value = 1.5,
      default = 1,
      duration = 20,
      startMessage = "jump boosted by ",
      startMessageValue = true,
      endMessage = "jump boost expired",
    },
  },
}
