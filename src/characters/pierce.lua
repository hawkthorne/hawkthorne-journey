return {
    name = 'pierce',
    offset = 2,
    ow = 5,
    costumes = {
        {name='Pierce Hawthorne', sheet='base'},
        {name='Astronaut', sheet='astronaut'},
        {name='Birthday Suit', sheet='naked'},
        -- {name='Beastmaster', sheet='beast'},
        {name='Canoe', sheet='canoe'},
        {name='Captain Kirk', sheet='kirk'},
        {name='Drugs', sheet='drugs'},
        -- {name='Cookie Crisp Wizard', sheet='cookie'},
        {name='Hotdog', sheet='hotdog'},
        {name='Hula Paint Hallucination', sheet='hulapaint'},
        {name='Janet Reno', sheet='janetreno'},
        {name='The Gimp', sheet='gimp'},
        lotus = 'Level 5 Laser Lotus',
        {name='Magnum', sheet='magnum'},
        {name='Paintball Trooper', sheet='paintball'},
        {name='Planet Christmas', sheet='planet_christmas'},
        {name='Wheelchair', sheet='wheelchair'},
        {name='Zombie', sheet='zombie'},
        -- {name='Pillow Man', sheet='pillow'}
    },
    animations = {
        dead = {
            right = {'once', {'6,2'}, 1},
            left = {'once', {'6,1'}, 1}
        },
        jump = {
            right = {'once', {'7,2'}, 1},
            left = {'once', {'7,1'}, 1}
        },
        hold = {
            right = {'once', {'7,12'}, 1},
            left = {'once', {'7,11'}, 1}
        },
        holdwalk = { 
            right = {'loop', {'1-4,14'}, 0.16},
            left = {'loop', {'1-4,13'}, 0.16}
        },
        walk = {
            right = {'loop', {'2-5,2'}, 0.16},
            left = {'loop', {'2-5,1'}, 0.16}
        },
        idle = {
            right = {'once', {'1,2'}, 1},
            left = {'once', {'1,1'}, 1}
        },
        crouch = {
            right = {'once', {'3,6'}, 1},
            left = {'once', {'3,5'}, 1}
        },
        crouchwalk = { --state for walking towards the camera
            right = {'loop', {'2-3,3'}, 0.16},
            left = {'loop', {'2-3,3'}, 0.16}
        },
        attack = {
            left = {'loop', {'6,5', '8,5'}, 0.16},
            right = {'loop', {'6,6', '8,6'}, 0.16}
        },
        attackjump = {
            left = {'loop', {'7,3','9,3'}, 0.16},
            right = {'loop', {'7,4','9,4'}, 0.16}
        },
        attackwalk = {
            left = {'loop', {'5,3','6,3','9,3','6,3'}, 0.16},
            right = {'loop', {'5,4','6,4','9,4','6,4'}, 0.16}
        },
        wieldwalk = { --state for walking while holding a weapon
            left = anim8.newAnimation('loop', g('5-6,3'), 0.16),
            right = anim8.newAnimation('loop', g('5-6,4'), 0.16),
        },
        wieldidle = { --state for standing while holding a weapon
            left = anim8.newAnimation('once', g(1,5), 1),
            right = anim8.newAnimation('once', g(1,6), 1),
        },
        wieldjump = { --state for jumping while holding a weapon
            left = anim8.newAnimation('once', g('5,3'), 1),
            right = anim8.newAnimation('once', g('5,4'), 1),
        },
        wieldaction = { --state for swinging a weapon
            left = anim8.newAnimation('once', g('5,4','6,4','9,4','6,4'), 0.09),
            right = anim8.newAnimation('once', g('5,5','6,5','9,5','6,5'), 0.09),
        },
        gaze = {
            right = {'once', {'8,2'}, 1},
            left = {'once', {'8,1'}, 1}
        },
        gazewalk = { --state for walking away from the camera
            right = {'loop', {'2-3,4'}, 0.16},
            left = {'loop', {'2-3,4'}, 0.16}
        },
        flyin = {'once', {'4,3'}, 1},
        warp = {'once', {'1-4,1'}, 0.08}
    }
}
