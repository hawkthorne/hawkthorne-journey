-- inculdes

return {
    width = 32,
    height = 32,  
    animations = {
        default = {
            'loop',{'1,1','2,1'},.5,
        },
    },

    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='Any useful info for me?' },
        { ['text']='This town is in ruins!' },
        { ['text']='Hello!' },
    },
    talk_responses = {
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