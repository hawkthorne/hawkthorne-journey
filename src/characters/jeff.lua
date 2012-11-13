return {
    name = 'jeff',
    offset = 5,
    ow = 4,
    costumes = {
        {name='Jeff Winger', sheet='base'},
        -- {name='Darkest Timeline', sheet='dark'},
        {name='Astronaut', sheet='astronaut'},
        {name='Asylum', sheet='asylum'},
        {name='Aviators', sheet='aviators'},
        {name='Birthday Suit', sheet='naked'},
        {name='David Beckham', sheet='david'},
        {name='Electrocuted', sheet='electro'},
        -- {name='Dean Pelton', sheet='dean'},
        {name='Goldblumming', sheet='goldblum'},
        {name='Heather Popandlocklear', sheet='poplock'},
        {name='King of Spades', sheet='spades'},
        {name='Kool Kat', sheet='cool'},
        {name='Mercury Poisoning', sheet='straightjacket'},
        {name='Mohawk', sheet='mohawk'},
        -- {name='Ricky Nightshade', sheet='ricky'},
        {name='Seacrest Hulk', sheet='hulk'},
        {name='Short Shorts', sheet='shorts'},
        {name='Sexy Cowboy', sheet='cowboy'},
        abeds_shirt = 'Spanish 101',
        {name='Tinkletown', sheet='anime'},
        {name='Zombie', sheet='zombie'}
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
