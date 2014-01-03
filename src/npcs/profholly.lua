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

    noinventory = "Sorry, blueberry. All I have is on the shelves!",
    nocommands = "Command is such a strong, ugly word.",

    stare = true,

    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='No Ghosting, huh?', ['option']={
            { ['text']='A long lonely tiiiiime' },
            { ['text']='Hungered for your touch' },
            { ['text']='My darling...' },
            { ['text']='Oh, my love...' },
        }},
        { ['text']='How to get an art credit.' },
        { ['text']='Hello, professor.' },
    },
    talk_responses = {
    ["Hello, professor."]={
        "Hello, my precious blueberry!",
	"I hope you've been having a fantastic adventure.",
    },
    ["A long lonely tiiiiime"]={
        "(Professor Holly grinds his teeth.)",
    },
    ["How to get an art credit."]={
        "Participation! You've just passed by being here!",
        "Congratulations, little blueberry!",
    },
    ["Oh, my love..."]={
        "(Professor Holly crushes the lump of clay in his hands. Hard.)",
    },
    ["My darling..."]={
        "(Professor Holly lets out a pained whimper.)",
    },
    ["Hungered for your touch"]={
        "(Professor Holly's right eye twitches slightly.)",
    },
    },
}