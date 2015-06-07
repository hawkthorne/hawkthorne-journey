-- inculdes
local Prompt = require 'prompt'
local Timer = require 'vendor/timer'
local controls = require('inputcontroller').get()
local Gamestate = require 'vendor/gamestate'
local Quest = require 'quest'
local quests = require 'npcs/quests/lotusquest'

return {
  width = 24,
  height = 48, 
  nocommands = 'No one commands me but the Great Buddha himself!',
  noinventory = "I don't have anything to sell at the moment, sorry!",
  animations = {
    default = {
      'loop',{'2,1','1,1','1,1','1,1','1,1','1,1','1,1','1,1','2,1','1,1','1,1','1,1'},.25,
    },
    walking = {
      'loop',{'1,1','2,1','3,1'},.2,
    },
  },

  stare = false,

  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='Who are you?' }, 
    { ['text']='I am looking for a quest!', freeze = true },
    { ['text']='Anything in these mines?' },

  },
  talk_responses = {
    ["Who are you?"]={
      "I am a follower of the {{blue_light}}Reformed Neo Buddhism Church{{white}}!",
      "I am merely a level 3 laser lotus at the moment, but I'll get there!",
    },
    ["Anything in these mines?"]={
      "We haven't fully explored the mines yet, but there's supposedly a lot of important documents in a library at the end of the tunnel!",
      "Spellbooks, scrolls, maps...you know the stuff.",
      "The key to the mine carts is in the {{red}}storage room{{white}}, but we still haven't gotten around to searching for it, we'll probably get to it later."
    },
  },
  talk_commands = {
  ['I am looking for a quest!'] = function (npc, player)
    Quest:activate(npc, player, quests.boulders)
    end,
  },
}