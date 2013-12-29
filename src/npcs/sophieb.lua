-- inculdes

return {
    width = 48,
    height = 48,  
    animations = {
        default = {
            'loop',{'1,1','1,1','1,1','1,1','1,1','1,1','1,1','1,1','2,1'},.5,
        },
    },

    direction = "right",
    donotfacewhentalking = true,

    talk_items = {
        { ['text']='i am done with you'},
        { ['text']='Will you play me a song?'},
        { ['text']='I missed the dance...'},
        { ['text']='Sophie B. Hawkins?!'},
    },
    talk_responses = {
    ["Sophie B. Hawkins?!"]={
        "The one and only!",
	"Hawthorne Wipes are a proud sponsor of Lilith Fair!",
    },
    ["I missed the dance..."]={
        "Aw, don't fret, hun!",
	"The night's still young, and my roadies will take forever to pack up.",
	"I can always play you a song or two in the meantime.",
    },
    ["Will you play me a song?"]={
        "Of course! Just give me the command.",
	"I keep my setlist there.",
    },
    },
}