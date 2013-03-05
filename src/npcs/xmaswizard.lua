local xmas = {}

xmas.sprite = love.graphics.newImage('images/npc/christmaswizard.png')
xmas.tickImage = love.graphics.newImage('images/menu/selector.png')
xmas.menuImage = love.graphics.newImage('images/npc/xmas-wizard-menu.png')
xmas.walk = false
xmas.stare = true

xmas.items = {
    -- { ['text']='exit' },
    -- { ['text']='inventory' },
    -- { ['text']='command' },
    -- { ['text']='talk', ['option']={
        { ['text']='i am done with you' },
        { ['text']='How do I get out of here?' }, 
        { ['text']='Professor Duncan?' },
        { ['text']='Who are you?' },
    -- }},
}

xmas.responses = {
    ["Who are you?"]={
        "I am a Christmas Wizard!",
        "And definitely not a psych professor.",
    },
    ["How do I get out of here?"]={
        "You must venture to the Cave of Frozen Memories,",
        "And there you shall find the exit.",
    },
    ["Professor Duncan?"]={
        "I do not have the slightest idea",
        "What you're talking about.",
    },
}

return xmas
