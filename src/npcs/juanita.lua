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

    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='You look very busy' },
        { ['text']='Any useful info for me?' },
        { ['text']='Donde esta...', ['option']={
            { ['text']='the sandpits?' },
            { ['text']='the town mayor?' },
            { ['text']='Gay Island?' },
            { ['text']='la biblioteca?' },
        }},
    },
    talk_responses = {
    ['You look very busy']={
        "Of course I am! Look at all this mess I have to clean up! It sucks being a cleaning person around these parts.",
        "You know, I am pretty darn sure that I'm the only one who does an honest day's work in this town",
    },
    ['Any useful info for me?']={
        "Items like bone are common around these parts, so they sell for cheap.",
        "If you want to earn more money, you're better off selling them over at the Forest Town.",
    },
    ['the town mayor?']={
        "The town mayor? Pshaw, that buffoon wearing the most colorful rag around here?",
        "He'll be down the street probably, stroking that stupid moustache all day long.",
    },
    ['the sandpits?']={
        "That's a dangerous place, you hear? Full of giant, nasty spiders.",
        "Let's see...If I remember correctly, there was a hidden trigger that when you pulled, the doorway would open.",
        "I have no idea what the trigger looks like, but I do know for a fact that it was near an unusually large shrub.",
    },
    ['la biblioteca?']={
        "la biblioteca? Sorry guy, I don't think anyone here's literate.",
        "That's a weird thing to ask, is that like the only Spanish word you know?",
    },    
    ['Gay Island?']={
        "Gay Island? Why, it's right across the river from us.",
        "Of course, no one can even get to them anymore anyways because te exit outta here's blocked off.",
    },
    },
}