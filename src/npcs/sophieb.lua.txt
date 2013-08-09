local sophieb = {}

sophieb.sprite = love.graphics.newImage('images/npc/sophieb.png')
sophieb.tickImage = love.graphics.newImage('images/menu/selector.png')
sophieb.menuImage = love.graphics.newImage('images/npc/sophie-menu.png')
sophieb.walk = false
sophieb.stare = true

sophieb.items = {
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

sophieb.responses = {
    ["who are you?"]={"Mi um a MuUnnn Meee-Ming!",},
    ["why are you mumbling?"]={"Mummmm?",},
    ["the dean's office"]={"Mummmf Ummm!",},
    ["the registrar"]={"Mum Ummf Ummm. Muuurk",},
    ["the ac repair school"]={"Mummf, 'Mor Oy 'un ut ent",},
    ["my valentine"]={"Mummentine?",},
    ["my dignity"]={"?",},
    ["magnitude"]={"Mummop, Mummop",},
}

return sophieb
