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
      duration = 5,
      startMessage = "invulnerability activated",
      endMessage = "invulnerability expired",
    },
  },
}
