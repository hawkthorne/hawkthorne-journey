local lifeQuad = love.graphics.newQuad( 13, 0, 13, 9, 26, 9)
local healthQuad = love.graphics.newQuad( 0, 0, 13, 12, 26, 12)
local healthImage = love.graphics.newImage( "images/tokens/health.png" )
--table of item,amount,cost

return {
    weapons = {
        {"mallet",2,350},
        {"longsword",1,300},
        {"mace",1,500},
        {"battleaxe",2,500},
        {"boneclub",6,55},
        {"bow",3,150},
        {"arrow",30,4},
        {"crimson_sword",1,320},
    },
    materials = {
        {"leaf",10,55},
        {"rock",15,30},
        {"stone",10,60},
        {"boulder",7,90},
        {"stick",15,30},
        {"bone",30,20},
        {"ember",20,65},
        {"fire",5,120},
    },
    consumables = {
        {"red_potion",10,75},
        {"white_potion",5,110},
        {"watermelon",2,130},
        {"tacomeat",1,450},
    },
    misc = {
        {"lightning",4,300}
    }
}
