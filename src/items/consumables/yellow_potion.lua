-- made by Nicko21
return{
  name = "yellow_potion",
  description = "Money Potion",
  type = "consumable",
  info = 'grants Money',
  MAX_ITEMS = 2,
  width = 24,
  consumable = {
    randEffect = {
      p = {0.1,0.2,0.3,0.5,0.7,1},
      {money = 700},
      {money = 200},
      {money = 100},
      {money = 50},
      {money = 25},
      {money = 5},
    },
  },
}
