-- inculdes
local Dialog = require 'dialog'
local prompt = require 'prompt'
local Timer = require('vendor/timer')
local Quest = require 'quest'
local telescope = require 'npcs/quests/telescopejuanquest'
local quests = require 'npcs/quests/alienquest'

return {
  width = 29,
  height = 48,
  greeting = 'Oh, so you are the one that got my message to come find me? You do not look like much...',
  animations = {
    default = {
      'loop',{'1,2'},.5,
    },
    walking = {
      'loop',{'3-5,2'},.2,
    },
  },
  walking = true,
  walk_speed = 36,
  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='Who are you?' },
    { ['text']='Any useful info for me?' },
    { ['text']='Talk about quests'},
  },
  enter = function(npc, previous)
      if Quest.alreadyCompleted(telesopejuan, player, telescope.alien) == false then
        npc.busy = true
        npc.state = 'hidden'
      end
  end,
  talk_commands = {
    ['Talk about quests']= function(npc, player)
      Quest:activate(npc, player, quests.alienquest)
      end,
  },
  talk_responses = {
    ['Who are you?']={
      "My name is {{green_light}}Juan{{white}}, an alien from another planet.",
      "I've' fallen in love with the Mexican food on this planet, so I've changed my name and decided to live among you.",
    },
    ['Any useful info for me?']={
      "I've sen some questionable people going and about around here.",
      "I think the entrance to the {{orange}}sandpits{{white}} should be somewhere here.",
    },
  },
}
