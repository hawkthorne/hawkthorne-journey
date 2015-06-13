-- inculdes
local prompt = require 'prompt'
local Dialog = require 'dialog'
local app = require 'app'
local utils = require 'utils'
local Player = require 'player'
local NodeClass = require('nodes/npc')

return {
  width = 32,
  height = 48,
  greeting = 'My name is {{red_light}}Juan{{white}}, I spend my days lazying around {{olive}}Tacotown{{white}}.', 
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
    { ['text']='More options...', ['option']={
      { ['text']='Lay off that booze, pal' },
      { ['text']='You own that goat farm?', freeze = true },
      { ['text']='Tell me about this place' },
      { ['text']='I could sure use a beer' },
    }},
    { ['text']='Any useful info for me?' },
    { ['text']='Donde esta...', ['option']={
      { ['text']='Castle Hawkthorne?' },
      { ['text']='the town blacksmith?' },
      { ['text']='the sandpits?' },
      { ['text']='la biblioteca?' },
    }},
  },
  talk_commands = {
    ['You own that goat farm?']= function(npc, player)
      if player.quest == 'Aliens! - Investigate Goat Farm' and npc.db:get('juan1-key', false) == false then
        local Item = require 'items/item'
        local itemNode = require ('items/keys/farm_key')
        local item = Item.new(itemNode, 1)
        if npc.db:get('juan1-negotiation', true) then
          Dialog.new ("So you wanna poke around my goat farm a bit huh? Yeah I'll let you in-- for a price...", function()
            npc.prompt = prompt.new("I'll lend you a spare key to the farm for {{orange}}60 coins{{white}}, how does that sound?", function(result)
            if result == 'Yes' then
              if player.money < 60 then
              Dialog.new("Hey, you don't even have 60 coins! Get out of here!", function()
              npc.menu:close(player)
              end)
              else
              Dialog.new("Pleasure doing business with you. Here's the spare key to the farm.", function()
              player.inventory:addItem(item, true)
              player.money = player.money - 60
              npc.db:set('juan1-key', true)
              npc.menu:close(player)    
              end)
              end
            else
              npc.prompt = prompt.new("Alright fine, how does {{orange}}40 coins{{white}} sound?", function(result2)
              if result2 == 'Yes' then
                if player.money < 40 then
                Dialog.new("Hey, you don't even have 40 coins! Get out of here!", function()
                npc.menu:close(player)
                end)
                else
                Dialog.new("Pleasure doing business with you. Here's the spare key to the farm.", function()
                player.money = player.money - 40
                player.inventory:addItem(item, true)
                npc.db:set('juan1-key', true)
                npc.menu:close(player)   
                end)
                end
              else
                Dialog.new("You cheapskate, I'm not doing business with you!", function()
                npc.db:set('juan1-negotiation', false)
                npc.menu:close(player)
                end)
              end
              end)
            end
            npc.menu:close(player)
            npc.prompt = nil
            end)
          end)             
        else
          npc.prompt = prompt.new("Alright you cheapskate, I'm not giving away the farm key for anything less than {{orange}}100 coins{{white}}.", function(result3)
          if result3 == 'Yes' then
            if player.money < 100 then
            Dialog.new("You don't even have 100 coins, get out of here you bum!", function()
            npc.menu:close(player)
            end)
            else
            Dialog.new("Pleasure doing business with you. See, you should have took my first offer and not have been greedy!", function()
            player.money = player.money - 100
            player.inventory:addItem(item, true)
            npc.db:set('juan1-key', true)
            npc.menu:close(player)   
            end)
            end
          else
            Dialog.new("You cheapskate, I'm not doing business with you!", function()
            npc.menu:close(player)
            end)
          end
          end) 
        end
      else
        Dialog.new("Yup, all mine. Gotta make a living somehow.", function()
        npc.menu:close(player)
        end)
      end
      player.freeze = false
    end,
  },
  talk_responses = {
    ['Lay off that booze, pal']={
      "Buzz off, guy. You're not my mother.",
      "Besides, I'm only on my 6th bottle of the day.",
    },
    ['I could sure use a beer']={
      "Well, you ain't getting any of mine.",
    },
    ['Tell me about this place']={
      "This stinkhole of a town? Nothing much to tell.",
      "There's {{red_light}}Senor Juan{{white}} and his goons guarding the passage out of the valley...",
      "Not that anyone's had a good reason to try and leave.",
    },
    ['Castle Hawkthorne?']={
      "I really hope you're not thinking of going there, that's a pretty darn dangrous place.",
      "That being said, the castle is {{red_dark}}northeast{{white}} of here, past {{olive}}Gay Island{{white}} and the {{olive}}Black Caverns{{white}}.",
    },
    ['the town blacksmith?']={
      "Sleeping on the streets somewhere, probably,",
      "He's one of the few employed guys around here, and he's the laziest out of all of us.",
    },
    ['the sandpits?']={
      "The {{olive}}sandpits{{white}}? Haven't heard anyone talk about that place in a while.",
      "I believe it's somewhere past the {{olive}}chili fields{{white}}, I hear the entrance is very well hidden though.",
    },
    ['la biblioteca?']={
      "The library? We don't got no library here.",
      "Is that like the only Spanish word you know?",
    },    
    ['Any useful info for me?']={
      "If you're thinking about going into the {{olive}}sandpits{{white}}, it would be a good idea to bring a weapon.",
      "I hear the ceiling is so low you can't even jump on enemies to hurt them.",
    },
  },
}