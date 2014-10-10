-- made by Nicko21
return{
  name = "keynana",
  description = "Gummy Key-nana",
  type = "consumable",
  MAX_ITEMS = 2,
  info = "grants invulnerability",
  width = 24,
  consumable = {
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
