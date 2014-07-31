-- inculdes
local Timer = require('vendor/timer')

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
        rave =  {
            'loop',{'5,1','6,1','7,1'},.15,
        },
        love =  {
            'loop',{'8,1','9,1'},.10,
        },
  },
 
    walking = true,
    walk_speed = 36,
 
    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='What are you carrying?'},
        { ['text']='Hello!' },
        { ['text']='This town is in ruins!', ['option'] ={
                { ['text']='How ?', ['option']={
                        { ['text']='I will overthrow him'},
                        { ['text']='Seems too hard'},
                        { ['text']='I will think about it'},
                        { ['text']='How do you know'},
                         }},
                { ['text']='He can not die' },
                { ['text']='Lets overthrow him?' },
                { ['text']='Get this town together!'},
        }},
       
   
    },
    talk_responses = {
    ["Hello!"]={
        "We don't take kindly to strangers these days,",
        "I suggest you move on quickly.",
    },
    ["This town is in ruins!"]={
        "Ever since that tyrant Hawkthorne started ruling,",
        "our town started falling apart into pieces. If only he were overthrown!",
    },
    ["What are you carrying?"]={
        "It's a piece of wood. The town blacksmith needs it to make his weapons.",
        "You can find him at the last house on the street.",
    },
    ["How ?"]={
        "I hear he has a castle far off",
        "It is a long and hard journey but rumor has it a big reward awaits an adventurer brave enough to try.",
    },
    ["He can not die"]={
        "You are probably right. His reign seems to go on forever!",
    },
    ["Lets overthrow him?"]={
        "I have a job carrying wood",
        "I can't just pack up and leave",
        "I am making money to support my family",
    },
    ["Get this town together!"]={
        "That is rude but I forgive you",
    },
    ["I will overthrow him"]={
        "Good luck just know",
        "It wont be easy",
        },
        ["Seems too hard"]={
        "true",
        "might as well try?",
        },
        ["I will think about it"]={
        "Think hard",
        "For this Journey will change you",
        },
        ["How do you know"]={
        "I just do",
        "Dont question",
        },
    ["marry"] ={
    	"I dont roll that way.",
    	"If you wanna find someone for a person like you,",
    	"Take a trip to gay island.",
    },
    ["directions"] ={
        "up, up, down, down",
        "oh %&$* i am lost",
    },
},

  command_items = { 
        { ['text']='die' }, 
        { ['text']='directions'},
        { ['text']='love'},
        { ['text']='rave'},   
     },

	command_commands = {   
        ['rave']=function(npc, player)
        	npc.walking = false
        	npc.stare = false
        	npc.state = "rave"
        	npc.busy = true
        	Timer.add(5, function()
				npc.state = "walking"
				npc.busy = false
				npc.walking = true
        	end)
    	end,

		['love']=function(npc, player)
			npc.walking = false
			npc.stare = false
			npc.state = "love"
			npc.busy = true
			Timer.add(3, function()
				npc.state = "walking"
				npc.busy = false
				npc.walking = true
			end)
		end,
	} 
}