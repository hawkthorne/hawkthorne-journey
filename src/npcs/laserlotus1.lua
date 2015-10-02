-- inculdes
local Prompt = require 'prompt'
local Timer = require 'vendor/timer'
local controls = require('inputcontroller').get()
local Gamestate = require 'vendor/gamestate'

return {
  width = 24,
  height = 48, 
  nocommands = 'I only take commands from a laser lotus above level 7 or the Great Buddha himself!',
  animations = {
    default = {
      'loop',{'1,1','1,1','1,1','1,1','1,1','1,1','1,1','1,1','2,1','1,1','1,1','1,1','1,1','1,1','1,1','4-5,1'},.25,
    },
    walking = {
      'loop',{'1,1','2,1','3,1'},.2,
    },
  },

  stare = false,

  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='Who are you?' }, 
    { ['text']='What cult is this?' },
    { ['text']='Why are you in a cave?' },

  },
  talk_responses = {
    ["inventory"]={
      "These are my wares. Every laser lotus above level five must carry a licensed sacred Buddha incense holder!",
      "Press {{yellow}}".. string.upper(controls:getKey('INTERACT')) .."{{white}} to view item information.",
    },
    ["Who are you?"]={
      "I am a follower of the {{blue_light}}Reformed Neo Buddhism Church{{white}}!",
      "I am merely a level 3 laser lotus at the moment, but I'll get there!",
    },
    ["What cult is this?"]={
      "It is not a cult, it's a way of life!",
      "When Buddha arrived in a meteor, he taught us forgiveness, love and lasers!",
      "When he returns, we shall bathe in the shimmering ocean of knowledge together!",
    },
    ["Why are you in a cave?"]={
      "Our headquarters is actually situated in a hidden valley in the mountains.",
      "This is simply just one of the many outposts we have.",
    },
  },

    inventory = function(npc, player)
    local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
    Gamestate.stack("shopping", player, screenshot, "laserlotus")
  end,
}
