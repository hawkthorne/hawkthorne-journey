local profholly = {}

profholly.sprite = love.graphics.newImage('images/npc/profholly.png')
profholly.tickImage = love.graphics.newImage('images/menu/selector.png')
profholly.menuImage = love.graphics.newImage('images/npc/profholly_menu.png')
profholly.walk = false
profholly.stare = true

profholly.items = {
    -- { ['text']='exit' },
    -- { ['text']='inventory' },
    -- { ['text']='command' },
    -- { ['text']='talk', ['option']={
        { ['text']='i am done with you' },
        { ['text']='No Ghosting, huh?', ['option']={
            { ['text']='A long lonely tiiiiime' },
            { ['text']='Hungered for your touch' },
            { ['text']='My darling...' },
            { ['text']='Oh, my love...' },
        }},
        { ['text']='How to get an art credit.' },
        { ['text']='Hello, professor.' },
    -- }},
}


profholly.responses = {
    ["Hello, professor."]={
        "Hello, my precious blueberry!",
	"I hope you've been having a fantastic adventure.",
    },
    ["A long lonely tiiiiime"]={
        "(Professor Holly grinds his teeth.)",
    },
    ["How to get an art credit."]={
        "Participation! You've just passed by being here!",
        "Congratulations, little blueberry!",
    },
    ["Oh, my love..."]={
        "(Professor Holly crushes the lump of clay in his hands. Hard.)",
    },
    ["My darling..."]={
        "(Professor Holly lets out a pained whimper.)",
    },
    ["Hungered for your touch"]={
        "(Professor Holly's right eye twitches slightly.)",
    },
}

return profholly

