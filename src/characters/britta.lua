return {
    name = 'britta',
    offset = 8,
    ow = 1,
    costumes = {
        {name='Britta Perry', sheet='base', category='base' },
        {name='Astronaut', sheet='astronaut', category='s2e4' },
        {name='Asylum', sheet='asylum', category='s3e19' },
        {name='Brittasaurus Rex', sheet='dragon', category='s2e6' },
        -- {name='Cheerleader', sheet='cheer', category='s1e13' },
        {name='Darkest Timeline', sheet='dark', category='s3e4' },
        -- {name='Goth Assistant', sheet='goth', category='s3e21' },
        {name='Kool Kat', sheet='cool', category='s2e13' },
        {name='Me So Christmas', sheet='king', category='s3e10' },
        {name='Modern Warfare', sheet='paintball', category='s1e23' },
        {name='Monster', sheet='dino', category='s2e6' },
        {name='Mute Tree', sheet='tree', category='s3e10' },
        {name='On Peyote', sheet='peyote', category='s3e19' },
        -- {name='Queen of Spades', sheet='spades', category='s2e23' },
        {name='Squirrel', sheet='squirrel', category='s1e7' },
        {name='Teapot', sheet='teapot', category='s1e14' },
        {name='Zombie', sheet='zombie', category='s2e6' }
    },
    animations = {
        dead = {
            right = {'once', {'10,2'}, 1},
            left = {'once', {'10,1'}, 1}
        },
        hold = {
            right = {'once', {'9,5'}, 1},
            left = {'once', {'8,5'}, 1}
        },
        holdwalk = { 
            right = {'loop', {'1,10', '8,8'}, 0.16},
            left = {'loop', {'1,11', '8,9'}, 0.16}
        },
        hurt = {
            right = {'once', {'6,2'}, 1},
            left = {'once', {'6,1'}, 1}
        },
        crouch = {
            right = {'once', {'4,4'}, 1},
            left = {'once', {'5,4'}, 1}
        },
        crouchwalk = { --state for walking towards the camera
            left = {'loop', {'2-3,3'}, 0.16},
            right = {'loop', {'2-3,3'}, 0.16}
        },
        gaze = {
            right = {'once', {'2,5'}, 1},
            left = {'once', {'1,5'}, 1}
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
            left = {'loop', {'9-10,6'}, 0.16},
            right = {'loop', {'9-10,7'}, 0.16}
        },
        attackwalk = {
            left = {'loop', {'4-7,10'}, 0.16},
            right = {'loop', {'4-7,11'}, 0.16},
        },
        wieldwalk = { --state for walking while holding a weapon
            left = {'loop', {'4,10','6,10'}, 0.16},
            right = {'loop', {'4,11','6,11'}, 0.16},
        },
        wieldidle = { --state for standing while holding a weapon
            left = {'once', {'8,1'}, 1},
            right = {'once', {'8,2'}, 1},
        },
        wieldjump = { --state for jumping while holding a weapon
            left = {'once', {'9,6'}, 1},
            right = {'once', {'9,7'}, 1},
        },
        wieldaction = { --state for swinging a weapon
            left = {'once', {'4,10','6,10','5,10','7,10'}, 0.09},
            right = {'once', {'4,11','6,11','5,11','7,11'}, 0.09},
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
            right = {'once', {1,2}, 1},
            left = {'once', {1,1}, 1}
        },
        flyin = {'once', {'4,3'}, 1},
        warp = {'once', {'1-4,1'}, 0.08}
    }
}
