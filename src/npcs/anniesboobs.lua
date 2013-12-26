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

    noinventory = "(The monkey points forward eagerly.)",
    nocommands = "(The monkey blows a raspberry at you.)",

    stare = false,

    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='Who is a good monkey?' },
        { ['text']='Did you see a purple pen?' },
        { ['text']='Hello!' },
    },

    talk_responses ={
    ['Hello!']={
        "Ook, ook, eek!",
    },
    ['Who is a good monkey?']={
        "SCREE!!!",
    },
    ['Did you see a purple pen?']={
        "(The monkey is more interested in the spoon than talking to you.)"
    },
    },
}