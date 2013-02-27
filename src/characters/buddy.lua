return {
    name = 'buddy',
    offset = 7,
    ow = 11,
    costumes = {
        {name='Buddy', sheet='base', category='base' },
        {name='Master Exploder', sheet='master_exploder', category='fanmade' }
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
