-- made by Nicko21
return{
  name = "chickenfinger",
  description = "Chicken Finger",
  type = "consumable",
  MAX_ITEMS = 1,
  consumable = {
    heal = "max",
    buff = {
      attribute = "invulnerable",
      value = true,
      default = false,
      duration = 10,
      startMessage = "invulnerability activated",
      endMessage = "invulnerability expired",
    },
  },
}
