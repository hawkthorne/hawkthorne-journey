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
    info        = '3 stones + 2 peanuts + 2 frogs + 4 eyes',
    name        = 'blue_potion',
    description = 'Jump Boost Potion Recipe',
  },
  {
  --invulnerability potion
  --in game (forest)
    recipe      = {boulder = 2, star = 1, ember = 3, fire = 3},
    info        = '2 boulders + 1 star + 3 emebers + 3 fires',
    name        = 'green_potion',
    description = 'Invunerability Potion Recipe', 
  },
  {
  --speed boost potion
  --in game (gay-island-2)
    recipe      = {bone = 2, mushroom = 1, duck = 2, frog = 1},
    info        = '2 bones + 1 mushroom + 2 ducks + 1 frog',
    name        = 'orange_potion',
    description = 'Speed Boost Potion Recipe',
  },
  {
  --max health potion
  --in game (black-caverns)
    recipe      = {peanut = 2, frog = 1, arm = 2, ember = 1},
    info        = '2 peanuts + 1 frog + 2 arms + 1 ember',
    name        = 'pink_potion',
    description = 'Max Health Potion Recipe',
  },
  {
  --punch damage potion
  --in game (treeline)
    recipe      = {stick = 1, rock = 2, leaf = 2},
    info        = '1 stick + 2 rocks + 2 leaves',
    name        = 'purple_potion',
    description = 'Punch Damage Potion Recipe',
  },
  {
  --health potion
  --in game (blacksmith-upstairs)
    recipe      = {leaf = 2, mushroom = 1, stick = 1, bone = 1},
    info        = '2 leaves + 1 mushroom + 1 stick + 1 bone',
    name        = 'red_potion',
    description = 'Health Potion Recipe',
  },
  {
  --greater health potion
  --in game (valley-sandpits-2)
    recipe      = {leaf = 3, mushroom = 1, stick = 2, duck = 1},
    info        = '3 leaves + 1 mushrrom + 2 sticks + 1 duck',
    name        = 'white_potion',
    description = 'Greater Health Potion Recipe',
  },
  {
  --money potion
  --in game (village-treeline)
    recipe       = {boulder = 3, frog = 1, star = 2, fire = 1},
    info         = '3 boulders + 1 frog + 2 stars + 1 fire',
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
    recipe       = {pancake = 1, banana = 1, toast = 1, bubblgum = 1, carkeys = 1},
    name         = 'chickenfinger',
  },
  {
  --chewy iron crepe
    recipe       = {pancake = 1, bubblgum = 3, carkeys = 3},
    name         = 'ironcrepe',
  },
  {
  --gummy keynana
    recipe       = {banana = 1, bubblgum = 6, carkeys = 3},
    name         = 'keynana',
  }
}
