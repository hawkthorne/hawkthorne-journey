return {
    name = 'annie',
    offset = 8,
    costumes = {
        {name='Annie Edison', sheet='base', category='base', ow = 1 },
        {name='Abed', sheet='abed', category='s3e16', ow = 2 },
        {name='Asylum', sheet='asylum', category='s3e19', ow = 3 },
        {name='Ace of Hearts', sheet='hearts', category='s2e23', ow = 4 },
        {name='Annie Kim', sheet='kim', category='s3e2', ow = 5 },
        {name='Armor', sheet='armor', category='s3e20', ow =6 },
        {name='Campus Security', sheet='security', category='s1e20', ow = 7 },
        {name='Finally Be Fine', sheet='befine', category='s3e1', ow = 8 },
        {name='Geneva', sheet='geneva', category='s3e16', ow = 9 },
        {name='Halloween', sheet='halloween', category='s3e5', ow = 10 },
        {name='Little Red Riding Hood', sheet='riding', category='s2e6', ow = 11 },
        {name='Modern Warfare', sheet='warfare', category='s1e23', ow = 12 },
        {name='Nurse', sheet='nurse', category='s3e14', ow = 13 },
        {name='Sexy Santa', sheet='santa', category='s3e10', ow = 14 },
        {name='Werewolf', sheet='werewolf', category='s3e5', ow = 15 },
        {name='Zombie', sheet='zombie', category='s3e20', ow =16 }
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
