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
  animations = {
    default = {
      'loop',{'1,2','1,2','1,2','1,2','1,2','1,2','1,2','1,2','2,2','1,2','1,2','1,2'},.25,
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
    ["inventory"]={
      "I don't have anything to sell at the moment, sorry!",
    },
    ["Who are you?"]={
      "I am a follower of the {{blue_light}}Reformed Neo Buddhism Church{{white}}!",
      "I am merely a level 3 laser lotus at the moment, but I'll get there!",
    },
    ["Anything in these mines?"]={
      "We haven't fully explored the mines yet, but there's supposedly some legendary weapon hidden at the very end that could slay the Acorn King!",
      "The key to the mine carts is in the storage room, but we still haven't gotten around to searching for it, we'll probably get to it later."
    },
  },
  talk_commands = {
  ['I am looking for a quest!'] = function (npc, player)
  player.quest = 'To Slay An Acorn - Search for the Weapon in the mines'
  player.freeze = false
      --Quest:activate(npc, player, quests.boulders)
    end,
  },
  inventory = function(npc, player)
    local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
    Gamestate.stack("shopping", player, screenshot, "laserlotus")
  end,
}