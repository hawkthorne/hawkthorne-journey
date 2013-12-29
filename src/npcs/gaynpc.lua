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
    menuColor = {r=255, g=255, b=255, a=255},
    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='Any useful info for me?' },
        { ['text']='What kind of place is this?' },
        { ['text']='Hello!' },
    },
    talk_responses = {
    ["Hello!"]={
        "Heeeyyyyyyyy-o,",
        "Gurl, today is a fab-tastic day.",
    },
    ["What kind of place is this?"]={
        "This place is FABULOUS!",
        "It's called Gay Island, home of the free and the fashionable.",
    },
    ["Any useful info for me?"]={
        "Uh-huh, for one, you should never wear those hideous colors together.",
        "That's a crime, that's what it is, the way you're wearing those rags.",
    },
    },
}