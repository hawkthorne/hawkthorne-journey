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
        { ['text']='Lay off that booze, pal' },
        { ['text']='Any useful info for me?' },
        { ['text']='Donde esta...', ['option']={
            { ['text']='Castle Hawkthorne?' },
            { ['text']='the town blacksmith?' },
            { ['text']='the sandpits?' },
            { ['text']='la biblioteca?' },
        }},
    },
    talk_responses = {
    ['Lay off that booze, pal']={
        "Buzz off, guy. You're not my mother.",
        "Besides, I'm only on my 6th bottle of the day.",
    },
    ['Castle Hawkthorne?']={
        "I really hope you're not thinking of going there, that's a pretty darn dangrous place.",
        "That being said, the castle is northeast of here, past Gay Island and the Black Caverns.",
    },
    ['the town blacksmith?']={
        "Sleeping on the streets somewhere, probably,",
        "He's one of the few employed guys around here, and he's the laziest out of all of us.",
    },
    ['the sandpits?']={
        "The sandpits? Haven't heard anyone talk about that place in a while.",
        "I believe it's somewhere past the chili fields, I hear the entrance is very well hidden though.",
    },
    ['la biblioteca?']={
        "The library? We don't got no library here.",
        "Is that like the only Spanish word you know?",
    },    
    ['Any useful info for me?']={
        "If you're thinking about going into the sandpits, it would be a good idea to bring a weapon.",
        "I hear the ceiling is so low you can't even jump on enemies to hurt them.",
    },
    },
}