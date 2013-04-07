return {
    name = 'chang',
    offset = 8,
    costumes = {
        {name='Ben Chang', sheet='base', category='base', ow = 1 },
        {name='Brutalitops', sheet='brutalitops', category='s2e14', ow = 2 },
        {name='Dictator', sheet='dictator', category='s3e21', ow = 3 },
        {name='Evil Chang', sheet='evil', category='s4promo', ow = 4 },
        {name='Father', sheet='father', category='s2e18', ow = 5 },
        {name='Safety First', sheet='safety', category='s1e24', ow = 6 }
    },
    animations = {
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
