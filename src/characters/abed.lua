return {
    name = 'abed',
    offset = 5,
    ow = 7,
    costumes = {
        {name='Abed Nadir', sheet='base', category='base' },
        {name='Alien', sheet='alien', category='s2e6' },
        {name='Batman', sheet='batman', category='s1e7' },
        {name='Bumblebee', sheet='bee', category='s2e13' },
        -- {name='Cooperative Calligraphy', sheet='bottle', category='s2e8' },
        {name='Christmas Sweater', sheet='christmas', category='s3e10' },
        {name='Covered In Paint', sheet='paint', category='s2e24' },
        {name='Cowboy', sheet='cowboy', category='s2e21' },
        {name='Evil Abed', sheet='evil', category='s3e22' },
        -- {name='Frycook', sheet='frycook', category='s2e21' },
        {name='Gangster', sheet='gangster', category='s3e19' },
        {name='Han Solo', sheet='solo', category='s2e24' },
        {name='Inspector Spacetime', sheet='inspector', category='s3e5' },
        -- {name='Jack of Clubs', sheet='clubs', category='s2e23' },
        {name='Jeff Roleplay', sheet='jeff', category='s3e16' },
        {name='Joey', sheet='white', category='s1e17' },
        {name='Morning', sheet='morning', category='s2e7' },
        {name='Mouse King', sheet='king', category='s3e10' },
        {name='Pierce Roleplay', sheet='pierce', category='s3e16' },
        -- {name='Pillowtown', sheet='pillow', category='s3e14' },
        -- {name='Rod the Plumber', sheet='rod', category='s3e21' },
        -- {name='Toga', sheet='toga', category='s1e22' },
        {name='Troy and Abed Sewn Together', sheet='sewn', category='s3e5' },
        {name='Zombie', sheet='zombie', category='s2e6' }
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
        hurt = {
            right = {'once', {'9,2'}, 1},
            left = {'once', {'9,1'}, 1}
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
