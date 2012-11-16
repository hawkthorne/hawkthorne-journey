return {
    name = 'dean',
    offset = 8,
    ow = 14,
    costumes = {
        {name='Dean Craig Pelton', sheet='base'},
        {name='Devil Dean', sheet='devil'},
        {name='Mardi Gras', sheet='mardigras'}
    },
    animations = {
        dead = {
            right = {'once', {'9,5'}, 1},
            left = {'once', {'9,6'}, 1}
        },
        hold = {
            right = {'once', {'1,7'}, 1},
            left = {'once', {'1,8'}, 1}
        },
        holdwalk = {
            right = {'loop', {'1-3,9', '2,9'}, 0.16},
            left = {'loop', {'1-3,10', '2,10'}, 0.16}
        },
        crouch = {
            right = {'once', {'1,6'}, 1},
            left = {'once', {'1,5'}, 1}
        },
        crouchwalk = { --state for walking towards the camera
            left = {'loop', {'8-9,1'}, 0.16},
            right = {'loop', {'8-9,1'}, 0.16}
        },
        gaze = {
            right = {'once', {'9,4'}, 1},
            left = {'once', {'9,3'}, 1}
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
            left = {'loop', {'4-5,3'}, 0.16},
            right = {'loop', {'4-5,4'}, 0.16}
        },
        attackwalk = {
            left = {'loop', {'2,6','4,6','6,6','4,6'}, 0.16},
            right = {'loop', {'2,5','4,5','6,5','4,5'}, 0.16}
        },
        jump = {
            right = {'once', {'1,4'}, 1},
            left = {'once', {'1,3'}, 1}
        },
        walk = {
            right = {'loop', {'5-7,2', '6,2'}, 0.16},
            left = {'loop', {'5-7,1', '6,1'}, 0.16}
        },
        idle = {
            right = {'once', {'1,2'}, 1},
            left = {'once', {'1,1'}, 1}
        },
        flyin = {'once', {'7,3'}, 1},
        warp = {'once', {'1-4,1'}, 0.08}
    }
}