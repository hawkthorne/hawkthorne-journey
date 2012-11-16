return {
    name = 'rich',
    offset = 2,
    ow = 16,
    costumes = {
        {name='Dr. Rich Stephenson', sheet='base'}
    },
    animations = {
        dead = {
            left = {'once', {'6,3'}, 1},
            right = {'once', {'6,4'}, 1}
        },
        hold = {
            left = {'once', {'7,8'}, 1},
            right = {'once', {'7,9'}, 1}
        },
        holdwalk = { 
            left = {'loop', {'1,10', '4,10'}, 0.16},
            right = {'loop', {'1,11', '4,11'}, 0.16}
        },
        crouch = {
            left = {'once', {'2,3'}, 1},
            right = {'once', {'2,4'}, 1}
        },
        crouchwalk = { --state for walking towards the camera
            left = {'loop', {'6,1', '7,1'}, 0.16},
            right = {'loop', {'6,1', '7,1'}, 0.16}
        },
        gaze = {
            left = {'once', {'3,3'}, 1},
            right = {'once', {'3,4'}, 1}
        },
        gazewalk = { --state for walking away from the camera
            left = {'loop', {'6,2', '7,2'}, 0.16},
            right = {'loop', {'6,2', '7,2'}, 0.16}
        },
        attack = {
            left = {'loop', {'1-2,14'}, 0.16},
            right = {'loop', {'3-4,14'}, 0.16}
        },
        attackjump = {
            left = {'loop', {'5-6,14'}, 0.16},
            right = {'loop', {'7-8,14'}, 0.16}
        },
        attackwalk = {
            left = {'loop', {'7,12', '2,13', '9,12', '2,13'}, 0.16},
            right = {'loop', {'4,13', '8,13', '6,13', '8,13'}, 0.16}
        },
        jump = {
            left = {'once', {'1,3'}, 1},
            right = {'once', {'1,4'}, 1}
        },
        walk = {
            left = {'loop', {'2-4,1', '3,1'}, 0.16},
            right = {'loop', {'2-4,2', '3,2'}, 0.16}
        },
        idle = {
            left = {'once', {'1,1'}, 1},
            right = {'once', {'1,2'}, 1}
        },
        flyin = {'once', {'1,5'}, 1},
        warp = {'once', {'1-4,1'}, 0.08}
    }
}