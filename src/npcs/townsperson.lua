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
    walk_speed = 36,

    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='This town is in ruins!' },
        { ['text']='What are you carrying?' },
        { ['text']='Hello!' },
    },
    talk_responses = {
    ["Hello!"]={
        "We don't take kindly to strangers these days,",
        "I suggest you move on quickly.",
    },
    ["This town is in ruins!"]={
        "Ever since that tyrant Hawkthorne started ruling,",
        "our town started falling apart into pieces. If only he were overthrown!",
    },
    ["What are you carrying?"]={
        "It's a piece of wood. The town blacksmith needs it to make his weapons.",
        "You can find him at the last house on the street.",
    },
    },
}