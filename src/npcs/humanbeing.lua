-- inculdes

return {
    width = 32,
    height = 48,
    animations = {
        default = {
            'loop',{'1,1','11,1'},.5,
        },
        walking = {
            'loop',{'1,1','2,1','3,1'},.2,
        },
    },

    noinventory = "Mum Mont Muve Mummfmen Mo Murm Muu.",
    nocommands = "Mum Mont Muurk Murunds Urm Muu.",

    stare = true,

    talk_items = {
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
    },
    talk_responses = {
    ["who are you?"]={"Mi um a MuUnnn Meee-Ming!",},
    ["why are you mumbling?"]={"Mummmm?",},
    ["the dean's office"]={"Mummmf Ummm!",},
    ["the registrar"]={"Mum Ummf Ummm. Muuurk",},
    ["the ac repair school"]={"Mummf, 'Mor Oy 'un ut ent",},
    ["my valentine"]={"Mummentine?",},
    ["my dignity"]={"?",},
    ["magnitude"]={"Mummop, Mummop",},
    },
}