return {
    name = 'britta',
    offset = 8,
    ow = 1,
    costumes = {
        {name='Britta Perry', sheet='base'},
        {name='Astronaut', sheet='astronaut'},
        {name='Asylum', sheet='asylum'},
        {name='Brittasaurus Rex', sheet='dragon'},
        -- {name='Cheerleader', sheet='cheer'},
        {name='Darkest Timeline', sheet='dark'},
        -- {name='Goth Assistant', sheet='goth'},
        {name='Kool Kat', sheet='cool'},
        {name='Me So Christmas', sheet='king'},
        {name='Modern Warfare', sheet='paintball'},
        {name='Monster', sheet='dino'},
        {name='Mute Tree', sheet='tree'},
        {name='On Peyote', sheet='peyote'},
        -- {name='Queen of Spades', sheet='spades'},
        {name='Squirrel', sheet='squirrel'},
        {name='Teapot', sheet='teapot'},
        {name='Zombie', sheet='zombie'}
    },
    animations = {
        dead = {
            right = {'once', {'10,2'}, 1},
            left = {'once', {'10,1'}, 1}
        },
        hold = {
            right = {'once', {9,5}, 1},
            left = {'once', {8,5}, 1}
        },
        holdwalk = { 
            right = {'loop', {'1,10', '8,8'}, 0.16},
            left = {'loop', {'1,11', '8,9'}, 0.16}
        },
        crouch = {
            right = {'once', {4,4}, 1},
            left = {'once', {5,4}, 1}
        },
        crouchwalk = { --state for walking towards the camera
            left = {'loop', {'2-3,3'}, 0.16},
            right = {'loop', {'2-3,3'}, 0.16}
        },
        gaze = {
            right = {'once', {2,5}, 1},
            left = {'once', {1,5}, 1}
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
            right = {'loop', {'4-7,11'}, 0.16}
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
