local lifeQuad = love.graphics.newQuad( 13, 0, 13, 9, 26, 9)
local lifeImage = love.graphics.newImage( "images/tokens/life.png" )
local healthQuad = love.graphics.newQuad( 0, 0, 13, 12, 26, 12)
local healthImage = love.graphics.newImage( "images/tokens/health.png" )
--table of item,amount,cost

return {
    weapons = {
        {"mallet",30,80},
        {"torch",3,100},
        {"sword",30,500},
        {"mace",30,500},
    },
    materials = {
        {"leaf",30,20},
        {"rock",30,15},
        {"stick",30,15},
        {"bone",30,50},
    },
    misc = {
        {"life",30,100,
            msg="gives the user an extra life",
            action= function(player)
                player.lives = player.lives + 1
            end,
            draw = function(x,y)
                love.graphics.drawq(lifeImage,lifeQuad,x,y)
            end,
        },
    },
}
