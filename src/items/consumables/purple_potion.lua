-- made by Nicko21
local Timer = require 'vendor/timer'
return{
  name = "purple_potion",
  description = "Punch Damage Potion",
  type = "consumable",
  MAX_ITEMS = 2,
  consumable = {
    buff = {
      attribute = "punchDamage",
      value = 5,
      default = 1,
      duration = 30,
      color = {98,44,99,255},
      startMessage = "punch damage boosted by ",
      startMessageValue = true,
      endMessage = "punch damage boost expired",
    },
  },
}
