local Prompt = require 'prompt'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'
local Quest = require 'quest'
local quests = require 'npcs/quests/telescopejuanquest'

return {
  width = 48,
  height = 48,  
  greeting = 'My name is {{red_light}}Juan{{white}}. I am the resident astronomer of {{olive}}Tacotown{{white}}.', 
  animations = {
    default = {
      'loop',{'1-2,1'},0.60,
    },
    startled = {
    'once',{'1,2','2,2'},0.50,
    },
    talking = {
      'loop',{'1,3','1,3','1,3','1,3','2,3'},0.5,
    }
  },

  donotfacewhentalking = true,

  begin = function(npc, player)
    npc.state = "startled"
    Timer.add(1,function()
      npc.state = "talking"
    end)
  end,
  finish = function(npc, player)
    npc.state = "default"
  end,

  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='Any useful info for me?' },
    { ['text']='So you believe in aliens?' },
    { ['text']='Hello!' },
  },

  talk_commands = {
    ['So you believe in aliens?']= function(npc, player)
      Quest:activate(npc, player, quests.alien)
    end,
  },

  talk_responses = {
    ["Hello!"]={
      "Careful, the aliens are here. Stay low, stay hidden!",
    },
    ["Any useful info for me?"]={
      "Be careful, the aliens could attack at any time!",
      "You will need many weapons and potions if you are to survive its attacks.",
    },
  },
}
