-----------------------------------------
-- potion_recipes.lua
-- Contains all the potion recipes that the player can use
-- Created by Nicko21
-----------------------------------------

return {
  {
  --jump boost potion
  --in game (valley-chili-fields)
    recipe      = {stone = 3, peanut = 2, frog = 2, eye = 4},
    info        = '3 stones \n 2 peanuts \n 2 frogs \n 4 eyes',
    name        = 'blue_potion',
    description = 'Jump Boost Potion Recipe',
  },
  {
  --invulnerability potion
  --in game (forest)
    recipe      = {boulder = 2, star = 1, ember = 3, fire = 3},
    info        = '2 boulders \n 1 star \n 3 emebers \n 3 fires',
    name        = 'green_potion',
    description = 'Invunerability Potion Recipe', 
  },
  {
  --speed boost potion
  --in game (gay-island-2)
    recipe      = {bone = 2, mushroom = 1, duck = 2, frog = 1},
    info        = '2 bones \n 1 mushroom \n 2 ducks \n 1 frog',
    name        = 'orange_potion',
    description = 'Speed Boost Potion Recipe',
  },
  {
  --max health potion
  --in game (black-caverns)
    recipe      = {peanut = 2, frog = 1, arm = 2, ember = 1},
    info        = '2 peanuts \n 1 frog \n 2 arms \n 1 ember',
    name        = 'pink_potion',
    description = 'Max Health Potion Recipe',
  },
  {
  --punch damage potion
  --in game (treeline)
    recipe      = {stick = 1, rock = 2, leaf = 2},
    info        = '1 stick \n 2 rocks \n 2 leaves',
    name        = 'purple_potion',
    description = 'Punch Damage Potion Recipe',
  },
  {
  --health potion
  --in game (blacksmith-upstairs)
    recipe      = {leaf = 2, mushroom = 1, stick = 1, bone = 1},
    info        = '2 leaves \n 1 mushroom \n 1 stick \n 1 bone',
    name        = 'red_potion',
    description = 'Health Potion Recipe',
  },
  {
  --greater health potion
  --in game (valley-sandpits-2)
    recipe      = {leaf = 3, mushroom = 1, stick = 2, duck = 1},
    info        = '3 leaves \n 1 mushrrom \n 2 sticks \n 1 duck',
    name        = 'white_potion',
    description = 'Greater Health Potion Recipe',
  },
  {
  --money potion
  --in game (village-treeline)
    recipe       = {boulder = 3, frog = 1, star = 2, fire = 1},
    info         = '3 boulders \n 1 frog \n 2 stars \n 1 fire',
    name         = 'yellow_potion',
    description  = 'Money Potion Recipe',
  },
  {
  --brekwich
    recipe       = {banana = 1, pancake = 2, toast = 2},
    name         = 'brekwich',
  },
  {
  --chicken finger
    recipe       = {pancake = 1, banana = 1, toast = 1, bubblegum = 1, carkeys = 1},
    name         = 'chickenfinger',
  },
  {
  --chewy iron crepe
    recipe       = {pancake = 1, bubblegum = 3, carkeys = 3},
    name         = 'ironcrepe',
  },
  {
  --gummy keynana
    recipe       = {banana = 1, bubblegum = 6, carkeys = 3},
    name         = 'keynana',
  }
}
