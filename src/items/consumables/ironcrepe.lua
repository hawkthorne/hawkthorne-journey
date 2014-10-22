-- made by Nicko21
return{
  name = "ironcrepe",
  description = "Chewy Iron Crepe",
  type = "consumable",
  info = "fortifies and maxamizes punches",
  MAX_ITEMS = 2,
  width = 24,
  consumable = {
    buff = {
      attribute = "punchDamage",
      value = 10,
      default = 1,
      duration = 35,
      startMessage = "punch damage boosted by ",
      startMessageValue = true,
      endMessage = "punch damage boost expired",
    },
  },
}
