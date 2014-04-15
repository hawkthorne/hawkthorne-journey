-- made by Nicko21
local Timer = require 'vendor/timer'
return{
  name = "green_potion",
  description = "Invulnerability Potion",
  type = "consumable",
  MAX_ITEMS = 2,
  consumable = {
    buff = {
      attribute = "invulnerable",
      value = true,
      default = false,
      duration = 5,
      color = {34,177,76,255},
      startMessage = "invulnerability activated",
      endMessage = "invulnerability expired",
    },
  },
}
