-- includes
local Prompt = require 'prompt'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'
local controls = require('inputcontroller').get()
local NodeClass = require('nodes/npc')

return {
  width = 72,
  height = 36,
  animations = {
    default = {
      'loop',{'1-5,1'},0.20,
    },
    talking = {
      'once',{'1-7,1','2,1','3,2','4,1'},0.20,
    },
    hide = {
      'once',{'8,1', '1-7,2', }, 0.20,
    },
    hidden = {
      'loop',{'8,2','1-4,3'}, 0.15,
    },
  },

  donotfacewhentalking = true,
  enter = function(npc, previous)
    
  end,
  
  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='How can I help?' },
    { ['text']='Any useful info for me?' },
    { ['text']='Hello!' },
  },
  talk_responses = {
    ["inventory"]={
      "These are my wares.",
      "Press {{yellow}}".. string.upper(controls:getKey('INTERACT')) .."{{white}} to view item information.",
    },
    ["Hello!"]={
      "Hello, I'm Greendale's bursar.",
      "I deal with the (small amount of) money around here.",
    },
    ["Anything happening here?"]={
      "We used to have a cult leader that claimed to specialize in alchemy stay in the house next door.",
      "What was odd was that he left with nothing and there was no alchemy equipment in the house at all.",
      "We think that he was just lying in an attempt to obtain followers.",
    },
    ["How can I help?"]={
      
      "Check out the list of current Greendale improvement projects.",
      "You can view them under my {{red}}INVENTORY{{white}}.",
      "Unless you've conveniently com into a couple million I don't see how you could help though.",
    },
  },
  inventory = function(npc, player)
    local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
    Gamestate.stack("shopping", player, screenshot, npc.name)
  end,

  update = function(dt, npc, player)

  end,

}