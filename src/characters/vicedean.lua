return {
    name = 'vicedean',
    offset = 2,
    ow = 8,
    costumes = {
        {name='Vice Dean Laybourne', sheet='base', category='base' },
        {name='Ghost', sheet='ghost', category='s3e22' },
        {name='Going Through Some Stuff', sheet='stuff', category='s3e13' },
        {name='Pajamas', sheet='pajamas', category='s3e13' }
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
