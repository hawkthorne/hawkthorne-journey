-- inculdes
local Dialog = require 'dialog'
local prompt = require 'prompt'
local Timer = require('vendor/timer')

return {
    width = 32,
    height = 48, 
    animations = {
        default = {
            'loop',{'11,1','11,1','11,1','10,1'},.5,
        },
        walking = {
            'loop',{'1,1'},.2,
        },

    },

	--walking = true,
    
    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='You look very busy', freeze = true },
        { ['text']='Any useful info for me?' },
        { ['text']='Donde esta...', ['option']={
            { ['text']='the sandpits?' },
            { ['text']='the town mayor?' },
            { ['text']='Gay Island?' },
            { ['text']='la biblioteca?' },
        }},
    },
	talk_commands = {
        ['You look very busy']=function(npc, player)
        	if player.quest~=nil and player.quest~='clean up town' then
            Dialog.new("You already have quest '" .. player.quest .. "' for " .. player.questParent .. "!", function()
            npc.menu:close(player)
            end)
          elseif player.quest=='clean up town' and not player.inventory:hasConsumable('alcohol') then
            Dialog.new("This place is a filthy!", function()
            npc.menu:close(player)
            end)
          elseif player.quest=='clean up town' and player.inventory:hasConsumable('alcohol') then
            Dialog.new("Thanks for helping clean up!  The town looks so much nicer!", function()
            npc:affectionUpdate(player:affectionUpdate('juanita',100))
        			player.inventory:removeManyItems(1,{name='alcohol',type='consumable'})
        			player.quest = nil
              npc.menu:close(player)
        		end)
  	      else
            Dialog.new("Of course I am! Look at all this mess I have to clean up! It sucks being a cleaning person around these parts.", function()
              Dialog.new("You know, I am pretty darn sure that I'm the only one who does an honest day's work in this town.", function()
                npc.prompt = prompt.new("Can you help me clean up by picking up some bottles?", function(result)
                  if result == 'Yes' then
                    player.quest = 'clean up town'
                    player.questParent = 'juanita'
                  end
                  npc.menu:close(player)
                  npc.fixed = result == 'Yes'
                  npc.prompt = nil
                  Timer.add(2, function() 
                    npc.fixed = false
                  end)
                end)
              end)
            end)
          end

    end,

	},
    talk_responses = {
    ['Any useful info for me?']={
        "Items like bone are common around these parts, so they sell for cheap.",
        "If you want to earn more money, you're better off selling them over at the Forest Town.",
    },
    ['the town mayor?']={
        "The town mayor? Pshaw, that buffoon wearing the most colorful rag around here?",
        "He'll be down the street probably, stroking that stupid moustache all day long.",
    },
    ['the sandpits?']={
        "That's a dangerous place, you hear? Full of giant, nasty spiders.",
        "Let's see...If I remember correctly, there was a hidden trigger that when you pulled, the doorway would open.",
        "I have no idea what the trigger looks like, but I do know for a fact that it was near an unusually large shrub.",
    },
    ['la biblioteca?']={
        "la biblioteca? Sorry guy, I don't think anyone here's literate.",
        "That's a weird thing to ask, is that like the only Spanish word you know?",
    },    
    ['Gay Island?']={
        "Gay Island? Why, it's right across the river from us.",
        "Of course, no one can even get to them anymore anyways because te exit outta here's blocked off.",
    },
    },
}