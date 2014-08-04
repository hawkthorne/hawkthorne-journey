-- inculdes
local sound = require 'vendor/TEsound'
local Timer = require('vendor/timer')
local tween = require 'vendor/tween'
local character = require 'character'
local gamestate = require 'vendor/gamestate'
local utils = require 'utils'
require 'utils'
local anim8 = require 'vendor/anim8'
local Dialog = require 'dialog'
local prompt = require 'prompt'

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
		sleep = {
            'loop',{'4,1'},.10,
		},
  },
 
    walking = true,
    walk_speed = 36,
 
    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='What are you carrying?'},
        { ['text']='Hello!' },
        { ['text']='This town is in ruins!', ['option'] ={
                { ['text']='i am done with you' },
                { ['text']='How?'},
                { ['text']='He can not die' },
                { ['text']='Overthrow him?' },
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
    ["How?"]={
        "I hear he has a castle far off",
        "It is a long and hard journey but rumor has it a big reward awaits an adventurer brave enough to try.",
    },
    ["He can not die"]={
        "Hawkthorne's reign seems to go on forever!  It's not natural!",
    },
    ["Overthrow him?"]={
        "I have a job carrying wood, I can't just pack up and leave!",
        "I am making money to support my family.",
    },
    ["marry"] ={
        "I dont roll that way, I'm already married.",
    },
    ["directions"] ={
        "up, up, down, down...",
        "&#%$ I'm lost",
    },
    ["yodel"] ={
        "Yodele yodele yodele",
        "Hee-hooo",
    },
    ["take a break"] ={
        "That's a great idea!",
    },
 
    },
	command_items = {
        { ['text']='more', ['option']={
        	{ ['text']='yodel'},
        	{ ['text']='take a break'},
        	{ ['text']='marry'},
        	{ ['text']='learn to love' },
        },},
    	{ ['text']='rave'},
    	{ ['text']='directions'},
    	{ ['text']='sticks'},  
     },
	command_commands = {   
		['sticks']=function(npc, player)
					npc.walking = false
					npc.stare = false                    
               
               if player.quest~=nil and player.quest~='collect sticks' then
				Dialog.new("You already have quest '" .. player.quest .. "' for " .. player.questParent .. "!", function()
				npc.walking = true
				npc.menu:close(player)
				end)
			   elseif player.quest=='collect sticks' and not player.inventory:hasMaterial('stick') then
				Dialog.new("Have you found any sticks?  Try looking in the forest.", function()
				npc.walking = true
				npc.menu:close(player)
				end)           
			   elseif player.quest=='collect sticks' and player.inventory:hasMaterial('stick') then
				Dialog.new("Thank you for the sticks, now I can feed my family!", function()
				npc:affectionUpdate(200)
            	player:affectionUpdate('townsperson',200)
						npc.walking = true
						player.inventory:removeManyItems(1,{name='stick',type='material'})
						player.quest = nil
				  npc.menu:close(player)
					end)
			   else
				Dialog.new("I must collect sticks for my boss at the lumber mill, or he won't pay me. I would do it myself but I am already carrying more than I can handle.", function()
				  Dialog.new("It would be great if somemone would help me!", function()
				    npc.prompt = prompt.new("Do you want to collect sticks for townsperson?", function(result)
						if result == 'Yes' then
							player.quest = 'collect sticks'
							player.questParent = 'townsperson'
						end
                  		npc.menu:close(player)
                  		npc.fixed = result == 'Yes'
                  		npc.walking = true
                  		npc.prompt = nil
                  		Timer.add(2, function() 
                    		npc.fixed = false
                  		end)
                	end)
              	end)
            end)
          end

    end,

        ['rave']=function(npc, player)
        	npc.walking = false
        	npc.stare = false
        	npc.state = "rave"
        	npc.busy = true
        	Timer.add(5, function()
				npc.state = "walking"
				npc.busy = false
				npc.walking = true
				npc:affectionUpdate(10)
            	player:affectionUpdate('townsperson',100)
            	npc.menu:close(player)
			end)
		end,

		['learn to love']=function(npc, player)
			local affection = player.affection.townsperson or 0

			if affection >= 500 then
				npc.walking = false
				npc.stare = false
				npc.state = "love"
				npc.busy = true
				Timer.add(3, function()
					npc.state = "walking"
					npc.busy = false
					npc.walking = true
				end)
			else 
          		Dialog.new("I barely know you!  My current affection for you is " .. affection .. ".", function()
              		npc.walking = true
              		npc.menu:close(player)
          		end)
          	end
		end,

		['take a break']=function(npc, player)
			npc.walking = false
			npc.stare = false
			npc.state = "sleep"
			npc.busy = true
			Timer.add(5, function()
				npc.state = "walking"
				npc.busy = false
				npc.walking = true
        end)
    end,
	}, 
}