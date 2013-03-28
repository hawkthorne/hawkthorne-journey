return {
    name = 'garrett',
    offset = 2,
    ow = 19,
    costumes = {
        {name='Garrett Lambert', sheet='base', category='base' },
    },
    animations = {
        walk = {
            left = {'loop', {'2-4,1'}, 0.16},
            right = {'loop', {'2-4,2'}, 0.16}
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
