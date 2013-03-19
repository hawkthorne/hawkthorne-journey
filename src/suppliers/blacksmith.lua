local lifeQuad = love.graphics.newQuad( 13, 0, 13, 9, 26, 9)
local lifeImage = love.graphics.newImage( "images/tokens/life.png" )
local healthQuad = love.graphics.newQuad( 0, 0, 13, 12, 26, 12)
local healthImage = love.graphics.newImage( "images/tokens/health.png" )
--table of item,amount,cost

return {
    weapons = {
        {"mallet",30,20},
        {"torch",3,500},
        {"sword",30,500},
    },
    materials = {
        {"leaf",30,5},
        {"rock",30,5},
        {"stick",30,5},
        {"bone",30,500},
    },
    keys = {
        {"greendale",1,1},
    },
    misc = {
        {"life",30,20,
            msg="gives the user an extra life",
            action= function(player)
                player.lives = player.lives + 1
            end,
            draw = function(x,y)
                love.graphics.drawq(lifeImage,lifeQuad,x,y)
            end,
        },
        {"hp",30,500,
            msg="increases the user's maximum hp",
            action= function(player)
                player.max_health = player.max_health + 1
                player.health = player.max_health
            end,
            draw = function(x,y)
                love.graphics.drawq(healthImage,healthQuad,x,y)
            end,
        },
    },
}
