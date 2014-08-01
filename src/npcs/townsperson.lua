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
    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='This town is in ruins!' },
        { ['text']='What are you carrying?' },
        { ['text']='Hello!' },
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
    ["die"] ={
        "Are you trying to kill me?"
    },
    ["marry"] ={
        "I dont roll that way.",
        "If you wanna find someone for a person like you,",
        "Take a trip to gay island.",
    },
 
    },
  command_items = {
        { ['text']='learn to love' },
        { ['text']='sticks'},
        { ['text']='marry'},
        { ['text']='rave'},
       
       
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