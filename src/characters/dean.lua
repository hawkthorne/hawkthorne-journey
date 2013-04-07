return {
    name = 'dean',
    offset = 8,
    costumes = {
        {name='Dean Craig Pelton', sheet='base', category='base', ow = 1 },
        {name='Devil Dean', sheet='devil', category='s3e5', ow = 2 },
        {name='Mardi Gras', sheet='mardigras', category='s2e21', ow = 3 },
        {name='Uncle Sam', sheet='unclesam', category='s2e17', ow = 4 }
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
