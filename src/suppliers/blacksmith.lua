local lifeQuad = love.graphics.newQuad( 13, 0, 13, 9, 26, 9)
local lifeImage = love.graphics.newImage( "images/tokens/life.png" )
local healthQuad = love.graphics.newQuad( 0, 0, 13, 12, 26, 12)
local healthImage = love.graphics.newImage( "images/tokens/health.png" )
--table of item,amount,cost

return {
    weapons = {
        {"mallet",2,80},
        {"torch",3,120},
        {"sword",3,100},
        {"longsword",1,300},
        {"mace",1,500},
        {"battleaxe",2,500},
        {"club",6,50},
        {"throwingknife",12,30},
    },
    materials = {
        {"leaf",30,20},
        {"rock",30,15},
        {"stick",30,15},
        {"bone",30,50},
    },
}
