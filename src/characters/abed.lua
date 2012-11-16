return {
    name = 'abed',
    offset = 5,
    ow = 7,
    costumes = {
        {name='Abed Nadir', sheet='base'},
        {name='Alien', sheet='alien'},
        {name='Batman', sheet='batman'},
        {name='Bumblebee', sheet='bee'},
        -- {name='Cooperative Calligraphy', sheet='bottle'},
        {name='Christmas Sweater', sheet='christmas'},
        {name='Covered In Paint', sheet='paint'},
        {name='Cowboy', sheet='cowboy'},
        {name='Evil Abed', sheet='evil'},
        -- {name='Frycook', sheet='frycook'},
        {name='Gangster', sheet='gangster'},
        {name='Han Solo', sheet='solo'},
        {name='Inspector Spacetime', sheet='inspector'},
        -- {name='Jack of Clubs', sheet='clubs'},
        {name='Jeff Roleplay', sheet='jeff'},
        {name='Joey', sheet='white'},
        {name='Morning', sheet='morning'},
        {name='Mouse King', sheet='king'},
        {name='Pierce Roleplay', sheet='pierce'},
        -- {name='Pillowtown', sheet='pillow'},
        -- {name='Rod the Plumber', sheet='rod'},
        -- {name='Toga', sheet='toga'},
        {name='Troy and Abed Sewn Together', sheet='sewn'},
        {name='Zombie', sheet='zombie'}
    },
    animations = {
        dead = {
            right = {'once', {'9,13'}, 1},
            left = {'once', {'9,14'}, 1}
        },
        hold = {
            right = {'once', {'5,5'}, 1},
            left = {'once', {'5,6'}, 1}
        },
        holdwalk = { 
            right = {'loop', {'1-3,9', '2,9'}, 0.16},
            left = {'loop', {'1-3,10', '2,10'}, 0.16}
        },
        holdjump = { 
            right = {'once', {'1,11'}, 1},
            left = {'once', {'1,12'}, 1},
        },
        crouch = {
            right = {'once', {'9,4'}, 1},
            left = {'once', {'9,3'}, 1}
        },
        crouchwalk = { --state for walking towards the camera
            left = {'loop', {'2-3,3'}, 0.16},
            right = {'loop', {'2-3,3'}, 0.16}
        },
        gaze = {
            right = {'once', {'8,2'}, 1},
            left = {'once', {'8,1'}, 1}
        },
        gazewalk = { --state for walking away from the camera
            left = {'loop', {'2-3,4'}, 0.16},
            right = {'loop', {'2-3,4'}, 0.16}
        },
        attack = {
            left = {'loop', {'3-4,6'}, 0.16},
            right = {'loop', {'3-4,5'}, 0.16}
        },
        attackjump = {
            left = {'loop', {'7-8,3'}, 0.16},
            right = {'loop', {'7-8,4'}, 0.16}
        },
        attackwalk = {
            left = {'loop', {'1,8','5,8','3,8','5,8'}, 0.16},
            right = {'loop', {'1,7','5,7','3,7','5,7'}, 0.16}
        },
        wieldwalk = { --state for walking while holding a weapon
            left = {'loop', {'4,8','5,8','6,8','5,8'}, 0.16},
            right = {'loop', {'4,7','5,7','6,7','5,7'}, 0.16},
        },
        wieldidle = { --state for standing while holding a weapon
            left = {'once', {'2,6'}, 1},
            right = {'once', {'2,5'}, 1},
        },
        wieldjump = { --state for jumping while holding a weapon
            left = {'once', {'7,1'}, 1},
            right = {'once', {'7,2'}, 1},
        },
        wieldaction = { --state for swinging a weapon
            left = {'once', {'6,8','9,8','3,8','6,8'}, 0.09},
            right = {'once', {'6,7','9,7','3,7','6,7'}, 0.09},
        },
        wieldaction2 = { --another state for swinging a weapon
            left = {'once', {'6,8','4,7','3,8','6,8'}, 0.09},
            right = {'once', {'6,7','4,8','3,7','6,7'}, 0.09},
        },
        jump = {
            right = {'once', {'7,2'}, 1},
            left = {'once', {'7,1'}, 1}
        },
        walk = {
            right = {'loop', {'2-4,2', '3,2'}, 0.16},
            left = {'loop', {'2-4,1', '3,1'}, 0.16}
        },
        idle = {
            right = {'once', {'1,2'}, 1},
            left = {'once', {'1,1'}, 1}
        },
        flyin = {'once', {'4,3'}, 1},
        warp = {'once', {'1-4,1'}, 0.08}
    }
}
