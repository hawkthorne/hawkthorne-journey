local jerry = {}

jerry.sprite = love.graphics.newImage('images/npc/jerry.png')
jerry.tickImage = love.graphics.newImage('images/menu/selector.png')
jerry.menuImage = love.graphics.newImage('images/npc/jerry-menu.png')
jerry.walk = true
jerry.stare = true

jerry.items = {
        { ['text']='i am done with you' },
        { ['text']='You have a gift.' },
        { ['text']='Listen to me.' },
        { ['text']='Hello!' },
}

jerry.responses = {
    ["Hello!"]={
        "Damn man! Aint you ever heard of knocking?!",
    },
    ["Listen to me."]={
        "Toilets and sinks...REAL THINGS!",
        "Things that people always use and always need to get fixed!",
    },
    ["You have a gift."]={
        "You could be a plumber!",
    },
}

return jerry
