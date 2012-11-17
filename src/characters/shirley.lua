return {
    name = 'shirley',
    offset = 9,
    ow = 2,
    costumes = {
        {name='Shirley Bennett', sheet='base'},
        {name='Ace of Clubs', sheet='clubs'},
        {name='Big Cheddar', sheet='anime'},
        {name='Chef', sheet='chef'},
        {name='Crayon', sheet='crayon'},
        {name='Harry Potter', sheet='potter'}
        -- {name='Jules Winnfield', sheet='jules'}
        -- {name='Not Miss Piggy', sheet='glenda'}
    },
    animations = {
        dead = {
            right = {'once', {'9,8'}, 1},
            left = {'once', {'9,7'}, 1}
        },
        hold = {
            right = {'once', {'2,12'}, 1},
            left = {'once', {'2,11'}, 1}
        },
        holdwalk = { 
            right = {'loop', {'3-4,14'}, 0.16},
            left = {'loop', {'3-4,13'}, 0.16}
        },
        hurt = {
            right = {'once', {'9,6'}, 1},
            left = {'once', {'9,5'}, 1}
        },
        crouch = {
            right = {'once', {'8,4'}, 1},
            left = {'once', {'8,3'}, 1}
        },
        crouchwalk = { --state for walking towards the camera
            right = {'loop', {'3-4,3'}, 0.16},
            left = {'loop', {'3-4,3'}, 0.16}
        },
        gaze = {
            right = {'once', {'6,4'}, 1},
            left = {'once', {'6,3'}, 1}
        },
        gazewalk = { --state for walking away from the camera
            right = {'loop', {'9,3-4'}, 0.16},
            left = {'loop', {'9,3-4'}, 0.16}
        },
        attack = {
            left = {'loop', {'2,9','5,9'}, 0.16},
            right = {'loop', {'2,10','5,10'}, 0.16}
        },
        attackjump = {
            left = {'loop', {'2,9','5,9'}, 0.16},
            right = {'loop', {'2,10','5,10'}, 0.16}
        },
        attackwalk = {
            left = {'loop', {'1,9','3,9','5,9','6,9'}, 0.16},
            right = {'loop', {'1,10','3,10','5,10','6,10'}, 0.16}
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
        flyin = {'once', {'2,3'}, 1},
        warp = {'once', {'1-4,1'}, 0.08}
    }
}
