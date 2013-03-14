-- this is the default sprite map for characters
-- individual characters should override anything that differs from this

return {
    -- rows 1 & 2
    idle = {
        left = {'once', {'1,1'}, 1},
        right = {'once', {'1,2'}, 1}
    },
    walk = {
        left = {'loop', {'2-4,1', '3,1'}, 0.16},
        right = {'loop', {'2-4,2', '3,2'}, 0.16}
    },
    gaze = { -- look up
        left = {'once', {'6,1'}, 1},
        right = {'once', {'6,2'}, 1}
    },
    depressed = { -- look down
        left = {'once', {'7,1'}, 1},
        right = {'once', {'7,2'}, 1}
    },
    towards = { -- looking towards
        left = {'once', {'8,1'}, 1},
        right = {'once', {'8,1'}, 1}
    },
    gazeidle = { -- looking away
        left = {'once', {'8,2'}, 1},
        right = {'once', {'8,2'}, 1}
    },
    crouchwalk = { -- walking towards
        left = {'loop', {'9-10,1'}, 0.16},
        right = {'loop', {'9-10,1'}, 0.16}
    },
    gazewalk = { -- walking away
        left = {'loop', {'9-10,2'}, 0.16},
        right = {'loop', {'9-10,2'}, 0.16}
    },
    profile = { -- facing directly to either side
        left = {'once', {'11,1'}, 1},
        right = {'once', {'11,2'}, 1}
    },
    profileaway = { -- facing away to either side ( opposite of idle )
        left = {'once', {'12,1'}, 1},
        right = {'once', {'12,1'}, 1}
    },
    
    -- rows 3 & 4
    jump = {
        left = {'once', {'1,3'}, 1},
        right = {'once', {'1,4'}, 1}
    },
    hurt = {
        left = {'once', {'4,3'}, 1},
        right = {'once', {'4,4'}, 1}
    },
    dead = {
        left = {'once', {'6,3'}, 1},
        right = {'once', {'6,4'}, 1}
    },
    acquire = {
        left = {'once', {'7,3'}, 1},
        right = {'once', {'7,4'}, 1}
    },
    slide = {
        left = {'once', {'8,3'}, 1},
        right = {'once', {'8,4'}, 1}
    },
    kick = {
        left = {'once', {'9,3'}, 1},
        right = {'once', {'9,4'}, 1}
    },
    punch = {
        left = {'once', {'10,3'}, 1},
        right = {'once', {'10,4'}, 1}
    },
    interact = {
        left = {'once', {'11-12,3'}, 0.16},
        right = {'once', {'11-12,4'}, 0.16}
    },
    
    --rows 5 & 6
    hold = {
        left = {'once', {'1,5'}, 1},
        right = {'once', {'1,6'}, 1}
    },
    holdwalk = {
        left = {'loop', {'2-3,5'}, 0.16},
        right = {'loop', {'2-3,6'}, 0.16}
    },
    holdjump = {
        left = {'once', {'6,5'}, 1},
        right = {'once', {'6,6'}, 1}
    },
    crouchhold = {
        left = {'once', {'7,5'}, 1},
        right = {'once', {'7,5'}, 1}
    },
    gazehold = {
        left = {'once', {'7,6'}, 1},
        right = {'once', {'7,6'}, 1}
    },
    crouchholdwalk = {
        left = {'loop', {'8-9,5'}, 0.16},
        right = {'loop', {'8-9,5'}, 0.16}
    },
    gazeholdwalk = {
        left = {'loop', {'8-9,6'}, 0.16},
        right = {'loop', {'8-9,6'}, 0.16}
    },
    crouch = {
        left = {'once', {'10,5'}, 1},
        right = {'once', {'10,6'}, 1}
    },
    kneel = {
        left = {'once', {'11,6'}, 1},
        right = {'once', {'11,6'}, 1}
    },
    flyin = {'once', {'12,5'}, 1},

    --rows 7 & 8
    throw = {
        left = {'once', {'1,7'}, 1},
        right = {'once', {'1,8'}, 1}
    },
    throwwalk = {
        left = {'loop', {'2-3,7'}, 0.16},
        right = {'loop', {'2-3,8'}, 0.16}
    },
    throwjump = {
        left = {'once', {'6,7'}, 1},
        right = {'once', {'6,8'}, 1}
    },
    drop = {
        left = {'once', {'7,7'}, 1},
        right = {'once', {'7,8'}, 1}
    },
    dropwalk = {
        left = {'loop', {'8-9,7'}, 0.16},
        right = {'loop', {'8-9,8'}, 0.16}
    },
    dropjump = {
        left = {'once', {'12,7'}, 1},
        right = {'once', {'12,8'}, 1}
    },
    
    --rows 9 & 10
    attack = {
        left = {'once', {'1,9', '5,9'}, 0.16},
        right = {'once', {'1,10', '5,10'}, 0.16}
    },
    attackjump = {
        left = {'once', {'4,9', '8,9'}, 0.16},
        right = {'once', {'4,10', '8,10'}, 0.16}
    },
    attackwalk = {
        left = {'once', {'2,9', '7,9'}, 0.16},
        right = {'once', {'2,10', '7,10'}, 0.16}
    },
    wieldwalk = { --state for walking while holding a weapon
        left = {'loop', {'2-3,9'}, 0.16},
        right = {'loop', {'2-3,10'}, 0.16},
    },
    wieldidle = { --state for standing while holding a weapon
        left = {'once', {'1,9'}, 1},
        right = {'once', {'1,10'}, 1},
    },
    wieldjump = { --state for jumping while holding a weapon
        left = {'once', {'4,9'}, 1},
        right = {'once', {'4,10'}, 1},
    },
    wieldaction = { --state for swinging a weapon
        left = {'once', {'2,9','10,9','6,9','2,9'}, 0.09},
        right = {'once', {'2,10','10,10','6,10','2,10'}, 0.09},
    },

    --rows 11 & 12
    -- ( do when arrows become a thing )

    --rows 13 & 14
    crawlidle = {
        left = {'once', {'1,13'}, 1},
        right = {'once', {'1,14'}, 1}
    },
    crawlwalk = {
        left = {'loop', {'1-4,13'}, 0.16},
        right = {'loop', {'1-4,14'}, 0.16}
    },
    crawlcrouchwalk = {
        left = {'loop', {'5-8,13'}, 0.16},
        right = {'loop', {'5-8,13'}, 0.16}
    },
    crawlgazewalk = {
        left = {'loop', {'5-8,14'}, 0.16},
        right = {'loop', {'5-8,14'}, 0.16}
    },
    dig = {
        left = {'loop', {'9-11,13'}, 0.16},
        right = {'loop', {'9-11,14'}, 0.16}
    },
    digidle = {
        left = {'once', {'9,13'}, 1},
        right = {'once', {'9,14'}, 1}
    },
    
    --rows 15 & 16
    push = {
        left = {'loop', {'1-3,15', '2,15'}, 0.16},
        right = {'loop', {'1-3,16', '2,16'}, 0.16}
    },
    pull = {
        left = {'loop', {'5-7,15', '6,15'}, 0.16},
        right = {'loop', {'5-7,16', '6,16'}, 0.16}
    },
    
    --extra
    warp = {'once', {'1-4,1'}, 0.08}
}