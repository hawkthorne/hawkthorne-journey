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
    { ['text']='How do I get out of here?', ['option']={
        { ['text']='more...', ['option']={
            { ['text']='i am done with you' },
            { ['text']='frog extinction' },
        }},
        { ['text']='i am done with you' },
        { ['text']='throne of hawkthorne' },
        { ['text']='for your hand' },
    }},
    { ['text']='stand aside' },
    },
    talk_responses = {
    ['madam, i am on a quest']={
        "I can help with that",
        "I have information on many topics...",
    },
	['i will wear your skin']={
        "My skin is my own.",
    },
		['stand aside']={
        "I'm sorry to see you go.",
    },
    ['throne of hawkthorne']={
        "The throne is in Castle Hawkthorne, north of here.",
    "You unlock the castle with the white crystal of discipline, which you must free from the black caverns.",
    },
	['for your hand']={
        "I cannot marry someone whom I do not truly love and trust.",
    },
    ['frog extinction']={
        "You know what? My prank is going to cause a sea of laughter,",
        "and I am going to watch you drown in it!",
    },
    
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