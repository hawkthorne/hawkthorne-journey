local oldman = {}

oldman.sprite = love.graphics.newImage('images/npc/oldman.png')
oldman.tickImage = love.graphics.newImage('images/menu/selector.png')
oldman.menuImage = love.graphics.newImage('images/npc/oldman-menu.png')
oldman.walk = false

oldman.items = {
        { ['text']='i am done with you' },
        { ['text']='Any useful info for me?' },
        { ['text']='This town is in ruins!' },
        { ['text']='Hello!' },
}

oldman.responses = {
    ["Hello!"]={
        "Piss off.",
    },
    ["This town is in ruins!"]={
        "Piss off.",
    },
    ["Any useful info for me?"]={
        "Piss off, would ya?",
    },
}

return oldman

