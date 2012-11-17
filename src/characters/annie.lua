return {
    name = 'annie',
    offset = 8,
    ow = 3,
    costumes = {
        {name='Annie Edison', sheet='base'},
        {name='Abed', sheet='abed'},
        {name='Asylum', sheet='asylum'},
        -- {name='Ace of Hearts', sheet='hearts'},
        {name='Annie Kim', sheet='kim'},
        {name='Armor', sheet='armor'},
        {name='Campus Security', sheet='security'},
        {name='Finally Be Fine', sheet='befine'},
        {name='Geneva', sheet='geneva'},
        {name='Little Red Riding Hood', sheet='riding'},
        {name='Modern Warfare', sheet='warfare'},
        {name='Nurse', sheet='nurse'},
        {name='Sexy Santa', sheet='santa'},
        {name='Zombie', sheet='zombie'}
    },
    animations = {
        dead = {
            right = {'once', {'9,2'}, 1},
            left = {'once', {'9,1'}, 1}
        },
        crouch = {
            right = {'once', {'9,5'}, 1},
            left = {'once', {'9,6'}, 1}
        },
        crouchwalk = { --state for walking towards the camera
            left = {'loop', {'2-3,3'}, 0.16},
            right = {'loop', {'2-3,3'}, 0.16}
        },
        hold = {
            right = {'once', {'5,7'}, 1},
            left = {'once', {'5,8'}, 1}
        },
        holdwalk = { 
            right = {'loop', {'7-9,9', '8,9'}, 0.16},
            left = {'loop', {'7-9,10', '8,10'}, 0.16}
        },
        hurt = {
            right = {'loop', {'1-2,5'}, 0.3},
            left = {'loop', {'1-2,6'}, 0.3}
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
            left = {'loop', {'7,6','6,6'}, 0.16},
            right = {'loop', {'7,5','8,5'}, 0.16}
        },
        attackjump = {
            left = {'loop', {'7,6','6,6'}, 0.16},
            right = {'loop', {'7,5','6,5'}, 0.16}
        },
        attackwalk = {
            left = {'loop', {'5,12','6,12','8,12','7,12'}, 0.16},
            right = {'loop', {'5,11','6,11','8,11','7,11'}, 0.16}
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
        flyin = {'once', {'1,3'}, 1},
        warp = {'once', {'1-4,1'}, 0.08}
    }
}
