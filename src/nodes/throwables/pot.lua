local game = require 'game'

return{
    name= 'pot',
    type= 'throwable',
    explode= {
        frameWidth = 41,
        frameHeight = 30,
        animation = {'once', {'1-5,1'}, .10},
        },
    holdXOffset= 2,
    holdYOffset= 0,    
} 
