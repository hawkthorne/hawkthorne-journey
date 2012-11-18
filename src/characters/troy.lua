return {
    name = 'troy',
    offset = 8,
    ow = 6,
    costumes = {
        {name='Troy Barnes', sheet='base'},
        -- {name='Barry the Plumber', sheet='barry'},
        -- {name='Blanketsburg', sheet='blanket'},
        {name='Bumblebee', sheet='bumblebee'},
        {name='Childish Gambino', sheet='gambino'},
        {name='Christmas Troy', sheet='christmas_tree'},
        {name='Constable Reggie', sheet='constable'},
        -- {name='Eddie Murphy', sheet='eddie'},
        {name='Detective', sheet='detective'},
        {name='Kickpuncher', sheet='kick'},
        -- {name='King of Clubs', sheet='clubs'},
        {name='Library Nerd', sheet='library'},
        {name='Michael Jackson', sheet='michaeljackson'},
        {name='Night Troy', sheet='night'},
        {name='Orange Paint', sheet='orange'},
        {name='Ripley', sheet='ridley'},
        {name='Pant Suit', sheet='pantsuit'},
        {name='Paintball', sheet='paintball'},
        {name='Sexy Dracula', sheet='sexyvampire'},
        {name='Spiderman', sheet='spidey'},
        {name='Star Quarterback', sheet='football'},
        {name='Troy and Abed Sewn Together', sheet='sewn'}
    },
    animations = {
        dead = {
            right = {'once', {'9,5'}, 1},
            left = {'once', {'9,6'}, 1}
        },
        hold = {
            right = {'once', {'5,6'}, 1},
            left = {'once', {'5,5'}, 1}
        },
        holdwalk = {
            right = {'loop', {'4-6,10', '5,10'}, 0.16},
            left = {'loop', {'4-6,9', '5,9'}, 0.16}
        },
        hurt = {
            right = {'loop', {'1,6', '1,8'}, 0.3},
            left = {'loop', {'1,5', '1,7'}, 0.3}
        },
        jump = {
            right = {'loop', {'5-7,2', '6,2'}, 0.10},
            left = {'loop', {'5-7,1', '6,1'}, 0.10}
        },
        walk = {
            right = {'loop', {'2-4,2', '3,2'}, 0.16},
            left = {'loop', {'2-4,1', '3,1'}, 0.16}
        },
        crouch = {
            right = {'once', {'9,2'}, 1},
            left = {'once', {'9,1'}, 1}
        },
        crouchwalk = { --state for walking towards the camera
            left = {'loop', {'3-4,3'}, 0.16},
            right = {'loop', {'3-4,3'}, 0.16}
        },
        gaze = {
            right = {'once', {'9,4'}, 1},
            left = {'once', {'9,3'}, 1}
        },
        gazewalk = { --state for walking away from the camera
            left = {'loop', {'2-3,4'}, 0.16},
            right = {'loop', {'2-3,4'}, 0.16}
        },
        attack = {
            left = {'loop', {'5,3','7,3'}, 0.16},
            right = {'loop', {'5,4','7,4'}, 0.16}
        },
        attackjump = {
            left = {'loop', {'5,3','7,3'}, 0.16},
            right = {'loop', {'5,4','7,4'}, 0.16}
        },
        attackwalk = {
            left = {'loop', {'1,11','3,11','7,11','3,11'}, 0.16},
            right = {'loop', {'1,12','3,12','7,12','3,12'}, 0.16}
        },
        idle = {
            right = {'once', {'1,2'}, 1},
            left = {'once', {'1,1'}, 1}
        },
        flyin = {'once', {'5,7'}, 1},
        warp = {'once', {'1-4,1'}, 0.08}
    }
}
