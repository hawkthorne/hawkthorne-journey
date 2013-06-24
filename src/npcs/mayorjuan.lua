local juan1 = {}

juan1.sprite = love.graphics.newImage('images/npc/mayorjuan.png')
juan1.tickImage = love.graphics.newImage('images/menu/selector.png')
juan1.menuImage = love.graphics.newImage('images/npc/mayorjuan_menu.png')
juan1.walk = false
juan1.items = {
    -- { ['text']='exit' },
    -- { ['text']='inventory' },
    -- { ['text']='command' },
    -- { ['text']='talk', ['option']={
        { ['text']='i am done with you' },
        { ['text']='Sick moustache!' },
        { ['text']='Donde esta...', ['option']={
            { ['text']='the Border Key?' },
            { ['text']='the town hall?' },
            { ['text']='the chili fields?' },
            { ['text']='la biblioteca?' },
        }},
        { ['text']='So you are the mayor?', ['option']={
            { ['text']='Why is the exit blocked?' },
            { ['text']='Why is the town so dirty?' },
            { ['text']='Tell me about this place' },
            { ['text']='How do I get out of here?' },
        }},
    -- }},
}

juan1.responses = {
    ['Sick moustache!']={
        "Why, thank you so much!",
        "I am very proud of my moustache, I comb it 20 times a day.",
    },
    ['the Border Key?']={
        "The border key? You thinking about getting out of here?",
	    "I believe it's hidden in the sandpits. Good luck finding that.",
    },
    ['the town hall?']={
        "A town hall?? That's ridiculous, what would I need a town hall for?",
        "I can run this town perfectly good without a town hall, thank you very much.",
    },
    ['the chili fields?']={
        "You can find the entrance to it at the shore when you first enter the valley",
        "There's a massive sign pointing the way, you'd have to be blind to miss it.",
    },
    ['la biblioteca?']={
        "A library? We don't have any libraries around here.",
        "Is that like the only Spanish word you know?",
    },    
    ['Why is the exit blocked?']={
        "That was not my doing, I can assure you that.",
        "It was that madman Cornelius. He and his goons set that up to prevent anybody from exiting the valley.",
    },
    ['Why is the town so dirty?']={
        "PFft, this is a clean enough town.",
        "I'm a busy, busy man, I've got better things to do than pick up litter.",
    },
    ['Tell me about this place']={
        "What is there to tell?",
        "I hear the ceiling is so low you can't even jump on enemies to hurt them.",
    },
    ['How do I get out of here?']={
        "If you're thinking about going into the sandpits, it would be a good idea to bring a weapon.",
        "I hear the ceiling is so low you can't even jump on enemies to hurt them.",
    },
}


return juan1
