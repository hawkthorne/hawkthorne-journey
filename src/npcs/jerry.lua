-- inculdes

return {
    width = 32,
    height = 48,
    animations = {
        default = {
            'loop',{'1,1','11,1'},.5,
        },
        walking = {
            'loop',{'1,1','2,1','3,1'},.2,
        },

    },

    walking = true,
    max_walk = 380,

    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='You have a gift.' },
        { ['text']='Listen to me.' },
        { ['text']='Hello!' },
    },
    talk_responses = {
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