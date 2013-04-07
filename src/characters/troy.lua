return {
    name = 'troy',
    offset = 8,
    costumes = {
        {name='Troy Barnes', sheet='base', category='base', ow = 1 },
        {name='Bing Bong', sheet='bingbong', category='s2e14', ow = 2 },
        {name='Bumblebee', sheet='bumblebee', category='s2e13', ow = 3 },
        {name='Childish Gambino', sheet='gambino', category='fanmade', ow = 4 },
        {name='Christmas Troy', sheet='christmas_tree', category='s1e12', ow = 5 },
        {name='Constable Reggie', sheet='constable', category='s3e6', ow = 6 },
        {name='Detective', sheet='detective', category='s3e17', ow = 7 },
        {name='Hobbes', sheet='hobbes', category='s4e2', ow = 8 },
        {name='Kickpuncher', sheet='kick', category='s1e15', ow = 9 },
        {name='Library Nerd', sheet='library', category='s3e17', ow = 10 },
        {name='Michael Jackson', sheet='michaeljackson', category='s3e12', ow = 11 },
        {name='Night Troy', sheet='night', category='s3e19', ow = 12 },
        {name='Orange Paint', sheet='orange', category='s2e24', ow = 13 },
        {name='Pant Suit', sheet='pantsuit', category='s2e15', ow = 14 },
        {name='Paintball', sheet='paintball', category='s1e23', ow = 15 },
        {name='Ripley', sheet='ridley', category='s2e6', ow = 16 },
        {name='Sexy Dracula', sheet='sexyvampire', category='s2e6', ow = 17 },
        {name='Spiderman', sheet='spidey', category='s2e1', ow = 18 },
        {name='Star Quarterback', sheet='football', category='s1e6', ow = 19 },
        {name='Troy and Abed Sewn Together', sheet='sewn', category='s3e5', ow = 20 }
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
