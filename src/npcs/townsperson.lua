local townsperson = {}

townsperson.sprite = love.graphics.newImage('images/npc/townsperson.png')
townsperson.tickImage = love.graphics.newImage('images/menu/selector.png')
townsperson.menuImage = love.graphics.newImage('images/npc/townsperson-menu.png')
townsperson.walk = true


townsperson.items = {
        { ['text']='i am done with you' },
        { ['text']='This town is in ruins!' },
        { ['text']='What are you carrying?' },
        { ['text']='Hello!' },
}

townsperson.responses = {
    ["Hello!"]={
        "We don't take kindly to strangers these days,",
        "I suggest you move on quickly.",
    },
    ["This town is in ruins!"]={
        "Ever since that tyrant Hawkthorne started ruling,",
        "our town started falling apart into pieces. If only he were overthrown!",
    },
    ["What are you carrying?"]={
        "It's a piece of wood. The town blacksmith needs it to make his weapons.",
        "You can find him at the last house on the street.",
    },
}
return townsperson
