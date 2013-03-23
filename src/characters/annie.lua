return {
    name = 'annie',
    offset = 8,
    ow = 3,
    costumes = {
        {name='Annie Edison', sheet='base', category='base' },
        {name='Abed', sheet='abed', category='s3e16' },
        {name='Asylum', sheet='asylum', category='s3e19' },
        {name='Ace of Hearts', sheet='hearts', category='s2e23' },
        {name='Annie Kim', sheet='kim', category='s3e2' },
        {name='Armor', sheet='armor', category='s3e20' },
        {name='Campus Security', sheet='security', category='s1e20' },
        {name='Finally Be Fine', sheet='befine', category='s3e1' },
        {name='Geneva', sheet='geneva', category='s3e16' },
        {name='Little Red Riding Hood', sheet='riding', category='s2e6' },
        {name='Modern Warfare', sheet='warfare', category='s1e23' },
        {name='Nurse', sheet='nurse', category='s3e14' },
        {name='Sexy Santa', sheet='santa', category='s3e10' },
        {name='Zombie', sheet='zombie', category='s3e20' }
    },
    animations = {
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
        },
        push = {
            left = {'loop', {'1-2,15'}, 0.16},
            right = {'loop', {'1-2,16'}, 0.16}
        }
    }
}
