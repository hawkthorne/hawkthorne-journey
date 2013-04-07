return {
    name = 'pierce',
    offset = 2,
    costumes = {
        {name='Pierce Hawthorne', sheet='base', category='base', ow = 1 },
        {name='Astronaut', sheet='astronaut', category='s2e4', ow = 5 },
        {name='Birthday Suit', sheet='naked', category='s3e20', ow = 16 },
        {name='Canoe', sheet='canoe', category='s1e19', ow = 3 },
        {name='Captain Kirk', sheet='kirk', category='s2e6', ow = 6 },
        {name='Drugs', sheet='drugs', category='s2e13',ow = 9 },
        {name='The Gimp', sheet='gimp', category='s2e19', ow = 10 },
        {name='Hotdog', sheet='hotdog', category='s2e21', ow = 11 },
        {name='Hula Paint Hallucination', sheet='hulapaint', category='s3e7', ow = 14 },
        {name='Janet Reno', sheet='janetreno', category='s1e16', ow = 2 },
        {name='Level 5 Laser Lotus', sheet='lotus', category='s2e3', ow = 4 },
        {name='Magnum', sheet='magnum', category='s3e5', ow = 13 },
        {name='Paintball Trooper', sheet='paintball', category='s2e24', ow = 12 },
        {name='Pillow Man', sheet='pillow', category='s3e14', ow = 17 },
        {name='Planet Christmas', sheet='planet_christmas', category='s3e10', ow = 15 },
        {name='Wheelchair', sheet='wheelchair', category='s2e9', ow = 8 },
        {name='Zombie', sheet='zombie', category='s2e6', ow = 7},
    },
    animations = {
        walk = {
            left = {'loop', {'2-5,1'}, 0.16},
            right = {'loop', {'2-5,2'}, 0.16}
        },
        holdwalk = {
            left = {'loop', {'2-5,5'}, 0.16},
            right = {'loop', {'2-5,6'}, 0.16}
        },
        throwwalk = {
            left = {'loop', {'2-5,7'}, 0.16},
            right = {'loop', {'2-5,8'}, 0.16}
        },
        dropwalk = {
            left = {'loop', {'8-11,7'}, 0.16},
            right = {'loop', {'8-11,8'}, 0.16}
        },
        push = {
            left = {'loop', {'1-4,15'}, 0.16},
            right = {'loop', {'1-4,16'}, 0.16}
        },
        pull = {
            left = {'loop', {'5-8,15'}, 0.16},
            right = {'loop', {'5-8,16'}, 0.16}
        }
    }
}
