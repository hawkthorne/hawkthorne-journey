-- made by Nicko21
return{
  name = "blue_potion",
  description = "Jump Boost Potion",
  type = "consumable",
  MAX_ITEMS = 2,
  consumable = {
    buff = {
      attribute = "jumpFactor",
      value = 1.5,
      default = 1,
      duration = 10,
      color = {0,145,206,255},
      startMessage = "jump boosted by ",
      startMessageValue = true,
      endMessage = "jump boost expired",
    },
  },
}
