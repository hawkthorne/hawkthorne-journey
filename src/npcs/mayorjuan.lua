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

    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='Sick moustache!' },
        { ['text']='Donde esta...', ['option']={
            { ['text']='the sandpits?' },
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
    },
    talk_responses = {
    ['Sick moustache!']={
        "Why, thank you so much!",
        "I am very proud of my moustache, I comb it 20 times a day.",
    },
    ['the sandpits?']={
        "The sandpits? You thinking about getting out of here?",
        "Alright, I'm technically not supposed to tell you this, but listen closely.",
        "Back before the spiders began infesting it, it was hidden in the chili fields.",
        "There is a secret lever in the shape of a cow's skull when pulled, would reveal the hidden entrance.",
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
        "Pfft, this is a clean enough town.",
        "I'm a busy, busy man, I've got better things to do than pick up litter.",
    },
    ['Tell me about this place']={
        "What is there to tell? Our town boasts the finest tacos in the world.",
        "It used to be a hub of festivals and siestas before that madman Cornelius took over.",
        "If only someone were to kick him off that throne...",
    },
    ['How do I get out of here?']={
        "The only way out of the Valley is back where you came from, to the forests.",
        "If you're going to continue on to Gay Island, you gotta go through the sandpits.",
        "The sandpits were used way back as a secret entrance, but we abandoned it when it was infested by giant spiders.",
    },
    },
}