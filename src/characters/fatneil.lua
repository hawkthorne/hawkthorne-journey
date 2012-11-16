return {
    name = 'fatneil',
    offset = 6,
    ow = 9,
    costumes = {
        {name='Fat Neil', sheet='base'}
    },
    animations = {
        dead = {
            right = {'once', {'4,6'}, 1},
            left = {'once', {'4,5'}, 1}
        },
        crouch = {
            right = {'once', {'3,6'}, 1},
            left = {'once', {'3,5'}, 1}
        },
        crouchwalk = { --state for walking towards the camera
            left = {'loop', {'3-4,3'}, 0.16},
            right = {'loop', {'3-4,3'}, 0.16}
        },
        hold = {
            right = {'once', {'7,9'}, 1},
            left = {'once', {'7,10'}, 1}
        },
        holdwalk = { --state for walking away from the camera
            left = {'loop', {'1-2,12'}, 0.16},
            right = {'loop', {'1-2,11'}, 0.16}
        },
        gaze = {
            right = {'once', {'5,2'}, 1},
            left = {'once', {'5,1'}, 1}
        },
        gazewalk = { --state for walking away from the camera
            left = {'loop', {'2-3,4'}, 0.16},
            right = {'loop', {'2-3,4'}, 0.16}
        },
        attack = {
            left = {'loop', {'8-9,1'}, 0.16},
            right = {'loop', {'8-9,2'}, 0.16}
        },
        attackjump = {
            left = {'loop', {'1-2,14'}, 0.16},
            right = {'loop', {'1-2,13'}, 0.16}
        },
        attackwalk = {
            left = {'loop', {'1,10','3,10','6,10','3,10'}, 0.16},
            right = {'loop', {'1,9','3,9','6,9','3,9'}, 0.16}
        },
        wieldwalk = { --state for walking while holding a weapon
            left = {'loop', {'1-3,10'}, 0.16},
            right = {'loop', {'1-3,9'}, 0.16},
        },
        wieldidle = { --state for standing while holding a weapon
            left = {'once', {'6,1'}, 1},
            right = {'once', {'6,2'}, 1},
        },
        wieldjump = { --state for jumping while holding a weapon
            left = {'once', {'1,14'}, 1},
            right = {'once', {'1,13'}, 1},
        },
        wieldaction = { --state for swinging a weapon
            left = {'once', {'1,10','2,10','4,10','5,10'}, 0.09},
            right = {'once', {'1,9','2,9','4,9','5,9'}, 0.09},
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
