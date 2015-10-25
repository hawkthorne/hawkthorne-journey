-- inculdes
local Dialog = require 'dialog'
local prompt = require 'prompt'


return {
  width = 48,
  height = 48,  
  animations = {
    default = {
      'loop',{'1,1'},.5,
    },
    walking = {
      'loop',{'2,1','3,1','4,1','5,1'},.2,
    },
  },
  greeting = "I'm {{red}}Officer Cackowski{{white}}.  There were reports of a disturbance, something about a bandit, and I'm patrolling the area.",

  walking = true,
  max_walk = 100,
  min_walk = 100,

  stare = false,

  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='Nice flashlight!' },
    { ['text']='Tell me something.' },
    { ['text']='You look farmiliar...' },
  },

  talk_commands = {
    ['Nice flashlight!'] = function (npc, player)
      Dialog.new("I had this sucker custom made.  I actually have an extra if you'd like one." , function()

        npc.prompt = prompt.new("Do you want Officer Cackowski's extra flashlight?", function(result)
	        if result == 'Yes' then
	          local Item = require 'items/item'
	          local itemNode = require ('items/keys/flashlight')
	          local item = Item.new(itemNode, 1)
	          player.inventory:addItem(item, true)
	          Dialog.currentDialog = nil
	          npc.menu:close(player)
	          npc.walking = true
	          npc.prompt = nil
	        end
	        if result == 'No' then
	        Dialog.new("Fair enough.", function()
	            Dialog.currentDialog = nil
	            npc.menu:close(player)
	            npc.walking = true
	            npc.prompt = nil
	          end)
	        end
        npc.fixed = result == 'Yes'
      	end)
       end)
    end,
    },

  talk_responses ={
    ['You look farmiliar...']={
      "You might be thinking of my sister {{red}}Liz Cackowski{{white}}, the Greendale guidance counselor.",
    },
    ['Tell me something.']={
      "Fact: in 100% of all fake gun shootings, the victim is always the one with the fake gun.",
    },
  },
}