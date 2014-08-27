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

    walking = true,

    talk_items = {
    { ['text']='i am done with you' },
    { ['text']='You look familiar...' },
    { ['text']='How do I get out of here?'},
    { ['text']='You look so worried!' },
    },
    talk_responses = {
    ['You look familiar...']={
        "My name is Tilda, I used to live in the village.",
        "When I was forced into marrying a man I did not love, I fled deep into these woods and now I fend for myself in the winderness.",   
        "You may have met my sister, Hilda. She and I resemble each other greatly.", 
    },
    ['How do I get out of here?']={
        "The mountain pass used to be open to all travellers, before Hawthorne took the throne and unleashed the Acorn King.",
        "Now it is blocked by a magical barrier that can only be opened by a key that the Acorn King personally carries around.",   
    },
    ['You look so worried!']={
        if player.quest 

        "Please, oh adventurer, we are in great need of a hero like yourself! I fear there is a sinister plot going on in these woods,",
        "one that may result in the very destruction of the Village. Will you not help me?",
           
    },
    tickImage = love.graphics.newImage('images/npc/hilda_heart.png'),
    command_items = { 
    { ['text']='back' },
    { ['text']='go home' },
    { ['text']='stay' }, 
    { ['text']='follow' },  
    },
    command_commands = {
    ['follow']=function(npc, player)
        npc.walking = true
        npc.stare = true
        npc.minx = npc.maxx
    end,
    ['stay']=function(npc, player)
        npc.walking = false
        npc.stare = false
    end,
    ['go home']=function(npc, player)
        npc.walking = true
        npc.stare = false
        npc.minx = npc.maxx - (npc.props.max_walk or 48)*2
    end,
    },
}