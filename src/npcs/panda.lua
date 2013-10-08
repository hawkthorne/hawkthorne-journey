local panda = {}

panda.sprite = love.graphics.newImage('images/npc/panda.png')
panda.tickImage = love.graphics.newImage('images/menu/selector.png')
panda.menuImage = love.graphics.newImage('images/npc/panda_menu.png')
panda.walk = false
panda.items = {
        { ['text']='I am done with you' },
        { ['text']='Any useful info for me?' },

        { ['text']='Do you know about...', ['option']={
            { ['text']='The Great Temple?' },
            { ['text']='Tanuki?' },
            { ['text']='Ancient Eastern Secret?' },
            { ['text']='the blocked bridge?' },
        }},
       { ['text']='Hello.' },
   -- }},
}

panda.responses = {
    ['Any useful info for me?']={
        "Be carefur! Evil magic make fake irrusions.",
        "Keep eyes open. Fakes have srightry different corers.",
    },
    ['the blocked bridge?']={
        "The work of troubresome Tanuki, I do berieve.",
        "He joined forces with Cornerius, brocked bridge with magic of Ancient Eastern Secret.",
    },
    ['Ancient Eastern Secret?']={
        "Ancient Eastern Secret, huh?",
        "It is magic scrorr, ancients use it to brock intruders.",
	"I bet you use it, you can unbrock bridge rickity-sprit!"
    },
    ['Tanuki?']={
        "Cornerius bribed him with shiny car, but Tanuki crashed it into pond.",
	"Ereven koi rost their rives, and Tanuki get much dishonor.",
        "Right now, Tanuki hiding in Great Tempre.",
    },    
    ['The Great Temple?']={
        "It is a tempre, and it is great.",
        "Key to tempre in Shrine of Qirin, up mountain in Bamboo Forest.",
        "Take reap of faith at very top, then touch idor rike you wourd a door.",
        "Be carefur! Tanuki use magic at Shrine. I hear strange noises.",
    },    
    ['Hello.']={
        "Herro! Wercome to the mountain!",
        "To make it arr the way here, you must have great disiprine.",
    },
}


return panda