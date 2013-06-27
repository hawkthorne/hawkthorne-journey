local lifeQuad = love.graphics.newQuad( 13, 0, 13, 9, 26, 9)
local healthQuad = love.graphics.newQuad( 0, 0, 13, 12, 26, 12)
local healthImage = love.graphics.newImage( "images/tokens/health.png" )
--table of item,amount,cost

return {
    weapons = {
        {"throwingknife",15,6},
        {"throwingaxe",12,8},
        {"mallet",2,350},
        {"longsword",1,300},
        {"mace",1,500},
        {"battleaxe",2,500},
        {"boneclub",6,55},
        {"bow",3,150},
        {"arrow",30,2},
    },
    materials = {
        {"leaf",10,55},
        {"rock",15,30},
        {"stone",10,45},
        {"boulder",10,45},
        {"stick",15,30},
        {"bone",30,20},
        {"ember",20,70},
    },
    consumables = {
        {"healthpotion",5,100},
    },
    misc = {
        {"lightning",3,300}
    }
}
