local human = {}

human.sprite = love.graphics.newImage('images/npc/human-being.png')
human.tickImage = love.graphics.newImage('images/menu/selector.png')
human.menuImage = love.graphics.newImage('images/npc/human-being_menu.png')
human.walk = false
human.stare = true

human.items = {
    -- { ['text']='exit' },
    -- { ['text']='inventory' },
    -- { ['text']='command' },
    -- { ['text']='talk', ['option']={
        { ['text']='i am done with you' },
        { ['text']='where is ...', ['option']={
            { ['text']='i am done with you' },
            { ['text']="the registrar" },
            { ['text']="the ac repair school" },
            { ['text']="my valentine" },
            { ['text']="my dignity" },
            { ['text']="magnitude" },
            { ['text']="the dean's office", },

        }},
        { ['text']='why are you mumbling?' },
        { ['text']='who are you?' },
    -- }},
}

human.responses = {
    ["who are you?"]={"Mi um a MuUnnn Meee-Ming!",},
    ["why are you mumbling?"]={"Mummmm?",},
    ["the dean's office"]={"Mummmf Ummm!",},
    ["the registrar"]={"Mum Ummf Ummm. Muuurk",},
    ["the ac repair school"]={"Mummf, 'Mor Oy 'un ut ent",},
    ["my valentine"]={"Mummentine?",},
    ["my dignity"]={"?",},
    ["magnitude"]={"Mummop, Mummop",},
}

return human
