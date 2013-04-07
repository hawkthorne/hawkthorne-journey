return {
    name = 'leonard',
    offset = 9,
    costumes = {
        {name='Leonard Rodriguez', sheet='base', category='base', ow = 1 },
        {name='Asylum', sheet='asylum', category='s3e19', ow = 2 }
    },
    animations = {
        walk = {
            left = {'loop', {'2-5,1'}, 0.16},
            right = {'loop', {'2-5,2'}, 0.16}
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
