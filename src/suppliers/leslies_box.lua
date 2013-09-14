local lifeQuad = love.graphics.newQuad( 13, 0, 13, 9, 26, 9)
local healthQuad = love.graphics.newQuad( 0, 0, 13, 12, 26, 12)
local healthImage = love.graphics.newImage( "images/tokens/health.png" )
--table of item,amount,cost

return {
    weapons = {
        {"throwingknife",25,10},
        {"throwingaxe",30,15},
        {"mallet",2,400},
        {"torch",3,200},
        {"sword",3,175},
        {"longsword",1,350},
        {"mace",1,600},
        {"battleaxe",2,500},
        {"boneclub",6,75},
        {"crimson_sword",2,2500},
        {"bow",3,200},
        {"arrow",50,5},

    },
    materials = {
        {"duck",30,70},
        {"banana",30,100},
        {"peanut",30,75},
        {"star",30,80},
        {"arm",30,90},
        {"frog",30,70},
    },
    consumables = {
        {"red_potion",5,100},
    },
    misc = {
        {"lightning",3,350}
    }
}
