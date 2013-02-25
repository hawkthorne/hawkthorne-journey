local townknight = {}

townknight.sprite = love.graphics.newImage('images/npc/townknight.png')
townknight.tickImage = love.graphics.newImage('images/menu/selector.png')
townknight.menuImage = love.graphics.newImage('images/npc/townknight-menu.png')
townknight.walk = false
townknight.stare = true

townknight.items = {
        { ['text']='i am done with you' },
        { ['text']='Any useful info for me?' },
        { ['text']='This town is in ruins!' },
        { ['text']='Hello!' },
}

townknight.responses = {
    ["Hello!"]={
        "A stranger! Haven't seen one of you in a while around here.",
        "Best be on guard, folk here don't take to strangers kindly these days.",
    },
    ["This town is in ruins!"]={
        "It's that damned Hawkthorne! He's a madman, that's what he is.",
        "Just sitting in that ivory tower of his, it's his fault we're in shambles like this.",
    },
    ["Any useful info for me?"]={
        "I hear Castle Hawkthorne holds untold riches, if anyone could get to them.",
        "One of them, I hear, is a key that unlocks a fabled world called Greendale.",
        "Now there's what I call a journey.",
    },
}

return townknight
