-- inculdes

return {
    width = 32,
    height = 48, 
    animations = {
        default = {
            'loop',{'3,1','4,1'},.5,
        },
        walking = {
            'loop',{'3,1','4,1','5,1'},.2,
        },

    },

    stare = true,

    talk_items = {
        { ['text']='I am done with you' },
        { ['text']='Who are you?' }, 
        { ['text']='I think I have seen you before' },
        { ['text']='Please do not attack me' },

    },
    talk_responses = {
    ["Who are you?"]={
        "I am an acorn.",
        "You might have seen others of my kind.",
		"That tyrant Hawkthorne put all of my kind under a spell to defend the forest",
		"I however am Immune for reasons I can not explain",
    },
    ["I think I have seen you before"]={
        "You may have seen others of my kind",
        "but do not worry I am different.",
    },
    ["Please do not attack me"]={
        "I would never",
        "Why would I ever do that?",
    },
    },
}