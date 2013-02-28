return {
    name = 'dean',
    offset = 8,
    ow = 14,
    costumes = {
        {name='Dean Craig Pelton', sheet='base', category='base' },
        {name='Devil Dean', sheet='devil', category='s3e5' },
        {name='Mardi Gras', sheet='mardigras', category='s2e21' },
        {name='Uncle Sam', sheet='unclesam', category='s2e17' }
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
