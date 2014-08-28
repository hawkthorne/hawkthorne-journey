-- inculdes

return {
    width = 32,
    height = 48,   
    greeting = 'My name is {{red_light}}Sir Merek{{white}}, I became a knight to protect this {{olive}}village{{white}} from the dangers of the forest.',
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
        { ['text']='Any useful info for me?' },
        { ['text']='This town is in ruins!' },
        { ['text']='Hello!' },
    },
    talk_responses = {
    ["Hello!"]={
        "A stranger! Haven't seen one of you in a while around here.",
        "Best be on guard, folk here don't take to strangers kindly these days.",
    },
    ["This town is in ruins!"]={
        "It's that damned {{grey}}Hawkthorne{{white}}! He's a madman, that's what he is.",
        "Just sitting in that ivory tower of his, it's his fault we're in shambles like this.",
    },
    ["Any useful info for me?"]={
        "I hear {{grey}}Castle Hawkthorne{{white}} holds untold riches, if anyone could get to them.",
        "One of them, I hear, is a key that unlocks a fabled world called {{olive}}Greendale{{white}}.",
        "Now there's what I call a journey.",
    },
    },
}