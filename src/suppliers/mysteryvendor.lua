local lifeQuad = love.graphics.newQuad( 13, 0, 13, 9, 26, 9)
local healthQuad = love.graphics.newQuad( 0, 0, 13, 12, 26, 12)
local healthImage = love.graphics.newImage( "images/tokens/health.png" )
--table of item,amount,cost

return {
    weapons = {
        {"throwingknife",25,10},


    },
    materials = {
        {"mushroom",20,30},
        {"duck",20,34},
        {"banana",30,45},
        {"peanut",30,40},
        {"star",30,85},
        {"arm",30,60},
    },

    keys = {
        {"Ladies Room",1,1000}
    }
}
