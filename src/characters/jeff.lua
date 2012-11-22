return {
    name = 'jeff',
    offset = 5,
    ow = 4,
    costumes = {
        {name='Jeff Winger', sheet='base', category='base' },
        -- {name='Darkest Timeline', sheet='dark', category='s3e4' },
        {name='Astronaut', sheet='astronaut', category='s2e4' },
        {name='Asylum', sheet='asylum', category='s3e19' },
        {name='Aviators', sheet='aviators', category='s3e12' },
        {name='Birthday Suit', sheet='naked', category='s1e17' },
        {name='David Beckham', sheet='david', category='s2e6' },
        {name='Electrocuted', sheet='electro', category='s3e20' },
        -- {name='Dean Pelton', sheet='dean', category='s3e8' },
        {name='Goldblumming', sheet='goldblum', category='s1e19' },
        {name='Heather Popandlocklear', sheet='poplock', category='s2e2' },
        {name='King of Spades', sheet='spades', category='s2e23' },
        {name='Kool Kat', sheet='cool', category='s2e13' },
        {name='Mercury Poisoning', sheet='straightjacket', category='s2e21' },
        {name='Mohawk', sheet='mohawk', category='s3e19' },
        -- {name='Ricky Nightshade', sheet='ricky', category='s3e21' },
        {name='Seacrest Hulk', sheet='hulk', category='s3e12' },
        {name='Short Shorts', sheet='shorts', category='s1e17' },
        {name='Sexy Cowboy', sheet='cowboy', category='s1e7' },
        {name='Spanish 101', sheet='abeds_shirt', category='s1e2' },
        {name='Tinkletown', sheet='anime', category='s3e9' },
        {name='Zombie', sheet='zombie', category='s2e6' }
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
        hurt = {
            right = {'loop', {'1-2,6'}, 0.3},
            left = {'loop', {'1-2,5'}, 0.3}
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
            left = {'loop', {'2,10','4,10'}, 0.16},
            right = {'loop', {'2,9','4,9'}, 0.16}
        },
        wieldwalk = { --state for walking while holding a weapon
            left = {'loop', {'1-3,10', '2,10'}, 0.16},
            right = {'loop', {'1-3,9','2,9'}, 0.16},
        },
        wieldidle = { --state for standing while holding a weapon
            left = {'once', {'8,1'}, 1},
            right = {'once', {'8,2'}, 1},
        },
        wieldjump = { --state for jumping while holding a weapon
            left = {'once', {'1,14'}, 1},
            right = {'once', {'1,13'}, 1},
        },
        wieldaction = { --state for swinging a weapon
            left = {'once', {'3,10','1,10','5,10','3,10'}, 0.09},
            right = {'once', {'3,9','1,9','5,9','3,9'}, 0.09},
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
