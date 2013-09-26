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

    walking = true,
    stare = true,

    items = {
        { ['text']='i am done with you' },
        { ['text']='You have a gift.' },
        { ['text']='Listen to me.' },
        { ['text']='Hello!' },
    },
    responses = {
    ["Hello!"]={
        "Damn man! Aint you ever heard of knocking?!",
    },
    ["Listen to me."]={
        "Toilets and sinks...REAL THINGS!",
        "Things that people always use and always need to get fixed!",
    },
    ["You have a gift."]={
        "You could be a plumber!",
    },
    },
}