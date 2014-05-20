-- inculdes

return {
    width = 27,
    height = 42,   
    animations = {
        default = {
            'loop',{'1,1'},.5,
        },
        walking = {
            'loop',{'1,2','2,2','3,2'},.2,
        },

    },

    walking = true,
    walk_speed = 10,

    
    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='What?' },
        { ['text']='Say again?' },
        { ['text']='Pardon?' },
    },
    talk_responses = {
    ["What?"]={
        "Speak up! I can't hear a thing you're sayin'!",
    },
    ["Say again?"]={
        "Speak up! I can't hear a thing you're sayin'!",
    },
    ["Pardon?"]={
        "Speak up! I can't hear a thing you're sayin'!",
    },
    },
}