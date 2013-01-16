return {
    name = 'pierce',
    offset = 2,
    ow = 5,
    costumes = {
        {name='Pierce Hawthorne', sheet='base', category='base' },
        {name='Astronaut', sheet='astronaut', category='s2e4' },
        {name='Birthday Suit', sheet='naked', category='s3e20' },
        -- {name='Beastmaster', sheet='beast', category='s1e7' },
        {name='Canoe', sheet='canoe', category='s1e19' },
        {name='Captain Kirk', sheet='kirk', category='s2e6' },
        {name='Drugs', sheet='drugs', category='s2e13' },
        -- {name='Cookie Crisp Wizard', sheet='cookie', category='s1e20' },
        {name='Hotdog', sheet='hotdog', category='s2e21' },
        {name='Hula Paint Hallucination', sheet='hulapaint', category='s3e7' },
        {name='Janet Reno', sheet='janetreno', category='s1e16' },
        {name='The Gimp', sheet='gimp', category='s2e19' },
        {name='Level 5 Laser Lotus', sheet='lotus', category='s2e3' },
        {name='Magnum', sheet='magnum', category='s3e5' },
        {name='Paintball Trooper', sheet='paintball', category='s2e24' },
        {name='Planet Christmas', sheet='planet_christmas', category='s3e10' },
        {name='Wheelchair', sheet='wheelchair', category='s2e9' },
        {name='Zombie', sheet='zombie', category='s2e6' },
        -- {name='Pillow Man', sheet='pillow', category='s3e14' }
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
        holdjump = { 
            right = {'once', {'1,10'}, 1},
            left = {'once', {'1,11'}, 1},
        },
        hurt = {
            right = {'once', {'2,6'}, 1},
            left = {'once', {'2,5'}, 1}
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
            left = {'loop', {'5-6,3'}, 0.16},
            right = {'loop', {'5-6,4'}, 0.16},
        },
        wieldidle = { --state for standing while holding a weapon
            left = {'once', {'1,5'}, 1},
            right = {'once', {'1,6'}, 1},
        },
        wieldjump = { --state for jumping while holding a weapon
            left = {'once', {'5,3'}, 1},
            right = {'once', {'5,4'}, 1},
        },
        wieldaction = { --state for swinging a weapon
            left = {'once', {'5,5','6,5','9,5','6,5'}, 0.09},
            right = {'once', {'5,4','6,4','9,4','6,4'}, 0.09},
        },
        gaze = {
            right = {'once', {'8,2'}, 1},
            left = {'once', {'8,1'}, 1}
        },
        gazeidle = { --state for looking away from the camera
            right = {'once', {'1,4'}, 1},
            left = {'once', {'1,4'}, 1},
        },
        gazewalk = { --state for walking away from the camera
            right = {'loop', {'2-3,4'}, 0.16},
            left = {'loop', {'2-3,4'}, 0.16}
        },
        flyin = {'once', {'4,3'}, 1},
        warp = {'once', {'1-4,1'}, 0.08}
    }
}
