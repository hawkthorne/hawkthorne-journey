local lifeQuad = love.graphics.newQuad( 13, 0, 13, 9, 26, 9)
local healthQuad = love.graphics.newQuad( 0, 0, 13, 12, 26, 12)
local healthImage = love.graphics.newImage( "images/tokens/health.png" )
--table of item,amount,cost

return {
    weapons = {
        {"throwingknife",15,6},
        {"throwingaxe",12,8},
        {"mallet",2,350},
        {"torch",3,120},
        {"sword",3,100},
        {"longsword",1,300},
        {"mace",1,500},
        {"battleaxe",2,500},
        {"club",6,50},
        {"boneclub",6,55},
        {"bow",3,150},
        {"arrow",30,2},

    },
    materials = {
        {"leaf",30,30},
        {"rock",30,20},
        {"stone",30,35},
        {"stick",30,15},
        {"bone",30,50},
        {"ember",30,70},
    },
    consumables = {
        {"red_potion",5,80},
    },
    misc = {
        {"lightning",3,300}
    }
}
