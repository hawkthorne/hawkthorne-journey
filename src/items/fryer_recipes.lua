-----------------------------------------
-- fryer_recipes.lua
-- Contains all the potion recipies that the player can use, plus bonus fried items
-- Created by Nicko21
-----------------------------------------

return {
    {
    --brekwich
        recipe={banana = 1, pancake = 2, toast = 2},
        name='brekwich',
    },
    {
    --chicken finger
        recipe={pancake = 1, banana = 1, toast = 1, bubblgum = 1, carkeys = 1},
        name='chickenfinger',
    },
    {
    --chewy iron crepe
        recipe={pancake = 1, bubblgum = 3, carkeys = 3},
        name='ironcrepe',
    },
    {
    --gummy keynana
        recipe={banana = 1, bubblgum = 6, carkeys = 3},
        name='keynana',
    },
    {
    --jump boost potion
        recipe={stone = 3, peanut = 2, frog = 2, eye = 4},
        name='blue_potion',
    },
    {
    --invulnerability potion
        recipe={boulder =2, star = 1, ember = 3, fire = 3},
        name='green_potion',
    },
    {
    --speed boost potion
        recipe={bone = 2, mushroom = 1, duck = 2, frog = 1},--
        name='orange_potion',
    },
    {
    --max health potion
        recipe={peanut = 2, frog = 1, arm = 2, ember = 1},
        name='pink_potion',
    },
    {
    --punch damage potion
        recipe={stick = 1, rock = 2, leaf = 2},
        name='purple_potion',
    },
    {
    --health potion
        recipe={leaf = 2, mushroom = 1, stick = 1, bone = 1},
        name='red_potion',
    },
    {
    --greater health potion
        recipe={leaf = 3, mushroom = 1, stick = 2, duck = 1},
        name='white_potion',
    },
    {
    --money potion
        recipe={boulder = 3, frog = 1, star = 2, fire = 1},--
        name='yellow_potion',
    }
}


