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
