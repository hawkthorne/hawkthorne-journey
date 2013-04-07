return {
    name = 'vicedean',
    offset = 2,
    costumes = {
        {name='Vice Dean Laybourne', sheet='base', category='base', ow = 1 },
        {name='Ghost', sheet='ghost', category='s3e22', ow = 2 },
        {name='Going Through Some Stuff', sheet='stuff', category='s3e13', ow = 3 },
        {name='Pajamas', sheet='pajamas', category='s3e13', ow = 4 }
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
