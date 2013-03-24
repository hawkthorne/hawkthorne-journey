return {
    name = 'troy',
    offset = 8,
    ow = 6,
    costumes = {
        {name='Troy Barnes', sheet='base', category='base' },
        -- {name='Barry the Plumber', sheet='barry', category='s3e21' },
        {name='Bing Bong', sheet='bingbong', category='s2e14' },
        -- {name='Blanketsburg', sheet='blanket', category='s3e14' },
        {name='Bumblebee', sheet='bumblebee', category='s2e13' },
        {name='Childish Gambino', sheet='gambino', category='fanmade' },
        {name='Christmas Troy', sheet='christmas_tree', category='s1e12' },
        {name='Constable Reggie', sheet='constable', category='s3e6' },
        -- {name='Eddie Murphy', sheet='eddie', category='s1e7' },
        {name='Detective', sheet='detective', category='s3e17' },
        {name='Hobbes', sheet='hobbes', category='s4e2' },
        {name='Kickpuncher', sheet='kick', category='s1e15' },
        -- {name='King of Clubs', sheet='clubs', category='s2e23' },
        {name='Library Nerd', sheet='library', category='s3e17' },
        {name='Michael Jackson', sheet='michaeljackson', category='s3e12' },
        {name='Night Troy', sheet='night', category='s3e19' },
        {name='Orange Paint', sheet='orange', category='s2e24' },
        {name='Pant Suit', sheet='pantsuit', category='s2e15' },
        {name='Paintball', sheet='paintball', category='s1e23' },
        {name='Ripley', sheet='ridley', category='s2e6' },
        {name='Sexy Dracula', sheet='sexyvampire', category='s2e6' },
        {name='Spiderman', sheet='spidey', category='s2e1' },
        {name='Star Quarterback', sheet='football', category='s1e6' },
        {name='Troy and Abed Sewn Together', sheet='sewn', category='s3e5' }
    },
    animations = {
        jump = {
            left = {'loop', {'1-3,3'}, 0.16},
            right = {'loop', {'1-3,4'}, 0.16}
        },
        wieldjump = {
            left = {'loop', {'1-3,3'}, 0.16},
            right = {'loop', {'1-3,4'}, 0.16}
        },
        hurt = {
            left = {'once', {'4-5,3'}, 1},
            right = {'once', {'4-5,4'}, 1}
        },
        holdwalk = {
            left = {'loop', {'2-4,5'}, 0.16},
            right = {'loop', {'2-4,6'}, 0.16}
        },
        throwwalk = {
            left = {'loop', {'2-4,7'}, 0.16},
            right = {'loop', {'2-4,8'}, 0.16}
        },
        dropwalk = {
            left = {'loop', {'8-10,7'}, 0.16},
            right = {'loop', {'8-10,8'}, 0.16}
        }
    }
}
