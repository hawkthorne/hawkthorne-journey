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

    stare = true,

    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='How do I get out of here?' }, 
        { ['text']='Professor Duncan?' },
        { ['text']='Who are you?' },

    },
    talk_responses = {
    ["Who are you?"]={
        "I am a Christmas Wizard!",
        "And definitely not a psych professor.",
    },
    ["How do I get out of here?"]={
        "You must venture to the Cave of Frozen Memories,",
        "And there you shall find the exit.",
    },
    ["Professor Duncan?"]={
        "I do not have the slightest idea",
        "What you're talking about.",
    },
    },
}