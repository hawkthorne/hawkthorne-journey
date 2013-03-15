local gayguy = {}

gayguy.sprite = love.graphics.newImage('images/npc/gaynpc.png')
gayguy.tickImage = love.graphics.newImage('images/menu/selector.png')
gayguy.menuImage = love.graphics.newImage('images/npc/gaynpc-menu.png')
gayguy.walk = false


gayguy.items = {
        { ['text']='i am done with you' },
        { ['text']='Any useful info for me?' },
        { ['text']='What kind of place is this?' },
        { ['text']='Hello!' },
}

gayguy.responses = {
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
}
return gayguy
