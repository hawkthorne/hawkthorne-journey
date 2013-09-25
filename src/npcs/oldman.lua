-- inculdes

return {
    width = 32,
    height = 48,
    bb_offset_x = 0,
    bb_offset_y = 0,
    bb_width = 32,
    bb_height = 48,    
    animations = {
        default = {
            'loop',{'1,1','11,1'},.5,
        },
        walking = {
            'loop',{'1,1','2,1','3,1'},.2,
        },

    },
    sounds = {},

    items = {
        { ['text']='i am done with you' },
        { ['text']='Any useful info for me?' },
        { ['text']='This town is in ruins!' },
        { ['text']='Hello!' },
    },
    responses = {
    ["Hello!"]={
        "Piss off.",
    },
    ["This town is in ruins!"]={
        "Piss off.",
    },
    ["Any useful info for me?"]={
        "Piss off, would ya?",
    },
    },
}