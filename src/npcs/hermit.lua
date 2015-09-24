local sound = require 'vendor/TEsound'
local Timer = require('vendor/timer')
local tween = require 'vendor/tween'
local character = require 'character'
local Gamestate = require 'vendor/gamestate'
local utils = require 'utils'
local anim8 = require 'vendor/anim8'
local Dialog = require 'dialog'
local Quest = require 'quest'
local quests = require 'npcs/quests/hermitquest'
local prompt = require 'prompt'

return {
  width = 24,
  height = 48,  
  animations = {
    default = {
        'loop',{'5,1','5,1','5,1','5,1','5,1','5,1','5,1','5,1','5,1','5,1','5,1','5,1','5,1','5,1','5,1','5,1','1,1','2,1','1,1','2,1'},0.28,
    },
  },

  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='Any useful info for me?' },
    { ['text']='Why do you live out here?' },
    { ['text']='Talk about quests' },
  },
  talk_commands = {
    ['Talk about quests'] = function(npc, player)
      if player.quest == 'To Slay an Acorn - Find the Old Hermit at Stonerspeak' then
        Quest.removeQuestItem(player)
        Quest:activate(npc, player, quests.berry)
      elseif player.quest == 'To Slay An Acorn - Collect the Special Berry' then
        Quest:activate(npc, player, quests.berry)
      else
        Dialog.new("The woods here are dangerous these days, you gotta keep your wits about you!", function()
          npc.menu:close(player)
        end)
      end
    end,
  },
  talk_responses = {
    ["Any useful info for me?"]={
      "There's a buncha' chests hidden around these parts for some reason, check them out to see what you get!",
    },
    ["Why do you live out here?"]={
      "The nature, the trees, the wee-I mean, the water.",
      "Though it's getting dangerous these days with all them angry acorns out and about...",
    },
  },
}