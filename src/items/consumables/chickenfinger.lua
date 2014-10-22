-- made by Nicko21
return{
  name = "chickenfinger",
  description = "Chicken Finger",
  type = "consumable",
  info = '"To victory. It feels unfamiliar but it tastes like chicken."',
  MAX_ITEMS = 1,
  width = 24,
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
