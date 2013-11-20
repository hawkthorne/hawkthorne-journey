local lifeQuad = love.graphics.newQuad( 13, 0, 13, 9, 26, 9)
local healthQuad = love.graphics.newQuad( 0, 0, 13, 12, 26, 12)
local healthImage = love.graphics.newImage( "images/tokens/health.png" )
--table of item,amount,cost

return {
    weapons = {
        {"blueskyspecial",1,10},


    },
    materials = {
        {"fries",99,25},
        {"pancake",99,100},
        {"banana",99,100},
        {"toast",99,100},
        {"carkeys",99,100},
        {"bubblegum",99,100},
    },

    keys = {
        {"Ladies Room",1,1000}
    }
}
