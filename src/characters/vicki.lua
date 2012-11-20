return {
    name = 'vicki',
    offset = 7,
    ow = 17,
    costumes = {
        {name='Vicki Cooper', sheet='base', category='base' }
    },
    animations = {
        dead = {
            right = {'once', {'3,5'}, 1},
            left = {'once', {'3,6'}, 1}
        },
        hold = {
            right = {'once', {'1,12'}, 1},
            left = {'once', {'1,11'}, 1}
        },
        holdwalk = { 
            right = {'loop', {'4,12', '1,12', '5,12', '1,12'}, 0.16},
            left = {'loop', {'4,11', '1,11', '5,11', '1,11'}, 0.16}
        },
        hurt = {
            right = {'loop', {'1,6','2,5'}, 0.3},
            left = {'loop', {'1,5','2,6'}, 0.3}
        },
        crouch = {
            right = {'once', {'7,4'}, 1},
            left = {'once', {'7,3'}, 1}
        },
        crouchwalk = { --state for walking towards the camera
            left = {'loop', {'3-4,3'}, 0.16},
            right = {'loop', {'3-4,3'}, 0.16}
        },
        gaze = {
            right = {'once', {'5,2'}, 1},
            left = {'once', {'5,1'}, 1}
        },
        gazewalk = { --state for walking away from the camera
            left = {'loop', {'3-4,4'}, 0.16},
            right = {'loop', {'3-4,4'}, 0.16}
        },
        attack = {
            left = {'loop', {'8-9,1'}, 0.16},
            right = {'loop', {'8-9,2'}, 0.16}
        },
        attackjump = {
            left = {'loop', {'1-2,13'}, 0.16},
            right = {'loop', {'1-2,14'}, 0.16}
        },
        attackwalk = {
            left = {'loop', {'1,9','6,9','3,9','6,9'}, 0.16},
            right = {'loop', {'1,10','6,10','3,10','6,10'}, 0.16}
        },
        wieldwalk = { --state for walking while holding a weapon
            left = {'loop', {'1-3,9'}, 0.16},
            right = {'loop', {'1-3,10'}, 0.16},
        },
        wieldidle = { --state for standing while holding a weapon
            left = {'once', {'8,1'}, 1},
            right = {'once', {'8,2'}, 1},
        },
        wieldjump = { --state for jumping while holding a weapon
            left = {'once', {'1,13'}, 1},
            right = {'once', {'1,14'}, 1},
        },
        wieldaction = { --state for swinging a weapon
            left = {'once', {'1,9','4,9'}, 0.09},
            right = {'once', {'1,10','4,10'}, 0.09},
        },
        jump = {
            left = {'once', {'7,1'}, 1},
            right = {'once', {'7,2'}, 1}
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
