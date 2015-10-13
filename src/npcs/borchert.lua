-- inculdes
local Dialog = require 'dialog'
local prompt = require 'prompt'
local Timer = require('vendor/timer')
local Quest = require 'quest'
local quests = require 'npcs/quests/juanitaquest'

return {
  width = 48,
  height = 48,
  greeting = 'I am {{red_light}}Russell Borchert{{white}}, anti-deodorant activist, and millionaire.',
  animations = {
    default = {
      'loop',{'1-4,1'},.5,
    },
  },
  stare = true,
  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='Money?', freeze = true },
    { ['text']='What is that thing?' },
    { ['text']='Who are you?'},
  },
  talk_commands = {
    ['Money?']= function(npc, player)
      if npc.trust < 1 then
        Dialog.new("I have a couple million Gerald Ford dollars in that bag over there. How about you leave me alone and I hereby grant this money to Greendale?", function()
          --taking in the inflation between 1974 and 2014 1 million gerald ford dollars would be worth ~5,044,350.65 USD
          player.money = player.money + 5044350
          npc.trust = npc.trust + 1
          npc.menu:close(player)
          Dialog.new("I hope you can put that money to good use fixing up Greendale.  I'm sure the Bursar knows what to fix up, her office is in the Administration Hallway.  Now leave me and Raquel alone!", function()
          	npc.menu:close(player)
        	end)
        end)

      else
        Dialog.new("I hope you can put that money to good use fixing up Greendale.  I'm sure the Bursar knows what to fix up, her office is in the Administration Hallway.  Now leave me and Raquel alone!", function()
          npc.menu:close(player)
        end)
      end
      
    end,
  },
  talk_responses = {
    ['Who are you?']={
      "I'm Russell Borchert. I founded Greendale in 1974 with money from the 9-track cassette player I invented.",
      "I allowed the Dean to seal me and the entire computer lab off from the rest of the campus while I worked on creating a computer that could process human emotion.",
    },
    ['What is that thing?']={
      "This is Raquel. She is the computer I created to respond to emotional stimuli.",
      "You can try her yourself. Just think about things that generate emotion, happy or sad.",
    },
  },
}
