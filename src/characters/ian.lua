return {
    name = 'ian',
    offset = 2,
    ow = 15,
    costumes = {
        {name='Ian Duncan', sheet='base'}
    },
    animations = {
        dead = {
            left = {'once', {'9,6'}, 1},
            right = {'once', {'9,5'}, 1}
        },
        hold = {
            left = {'once', {'1,8'}, 1},
            right = {'once', {'1,7'}, 1}
        },
        holdwalk = { 
            left = {'loop', {'1-3,10', '2,10'}, 0.16},
            right = {'loop', {'1-3,9', '2,9'}, 0.16}
        },
        crouch = {
            left = {'once', {'1,5'}, 1},
            right = {'once', {'1,6'}, 1}
        },
        crouchwalk = { --state for walking towards the camera
            left = {'loop', {'8-9,1'}, 0.16},
            right = {'loop', {'8-9,1'}, 0.16}
        },
        gaze = {
            left = {'once', {'9,3'}, 1},
            right = {'once', {'9,4'}, 1}
        },
        gazewalk = { --state for walking away from the camera
            left = {'loop', {'8-9,2'}, 0.16},
            right = {'loop', {'8-9,2'}, 0.16}
        },
        attack = {
            left = {'loop', {'2-3,4'}, 0.16},
            right = {'loop', {'2-3,3'}, 0.16}
        },
        attackjump = {
            left = {'loop', {'7-8,3'}, 0.16},
            right = {'loop', {'7-8,4'}, 0.16}
        },
        attackwalk = {
            left = {'loop', {'7,6', '5,14', '5,6', '5,14'}, 0.16},
            right = {'loop', {'5,5', '2,14', '7,5', '2,14'}, 0.16}
        },
        jump = {
            left = {'once', {'1,3'}, 1},
            right = {'once', {'1,4'}, 1}
        },
        walk = {
            left = {'loop', {'5-7,1', '6,1'}, 0.16},
            right = {'loop', {'5-7,2', '6,2'}, 0.16}
        },
        idle = {
            left = {'once', {'1,1'}, 1},
            right = {'once', {'1,2'}, 1}
        },
        flyin = {'once', {'7,3'}, 1},
        warp = {'once', {'1-4,1'}, 0.08}
    }
}
