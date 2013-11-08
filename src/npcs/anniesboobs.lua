local anniesboobs = {}

anniesboobs.sprite = love.graphics.newImage('images/npc/mayorjuan.png')
anniesboobs.tickImage = love.graphics.newImage('images/menu/selector.png')
anniesboobs.menuImage = love.graphics.newImage('images/npc/anniesboobs_menu.png')
anniesboobs.walk = false
anniesboobs.items = {
    -- { ['text']='exit' },
    -- { ['text']='inventory' },
    -- { ['text']='command' },
    -- { ['text']='talk', ['option']={
        { ['text']='i am done with you' },
        { ['text']='Who is a good monkey?' },
        { ['text']='Did you see a purple pen?' },
        { ['text']='Hello!' },
    -- }},
}

anniesboobs.responses = {
    ['Hello!']={
        "Ook, ook, eek!",
    },
    ['Who is a good monkey?']={
        "SCREE!!!",
    },
    ['Did you see a purple pen?']={
        "(The monkey is more interested in the spoon than talking to you.)"
    },
}


return anniesboobs
