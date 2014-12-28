-- inculdes
local Prompt = require 'prompt'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local controls = require('inputcontroller').get()
local Gamestate = require 'vendor/gamestate'

return {
  width = 48,
  height = 48,
  greeting = 'I am {{red_light}}Leslie{{white}}, I travel around looking for interesting wares that I can sell.', 
  animations = {
    default = {
      'loop',{'1,1','2,1','1,1','1,1','1,1','1,1'},0.5,
    },
  },
  direction = "left",
  donotfacewhentalking = true,
  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='Can I buy you a drink?' },
    { ['text']='Any useful info for me?' },
    { ['text']='Hello!' },
  },
  talk_responses = {
    ["inventory"]={
      "These are my wares. I crawled through dense bush to get 'em!",
      "Press {{yellow}}".. string.upper(controls:getKey('INTERACT')) .."{{white}} to view item information.",
    },
    ["Hello!"]={
      "Hello! I'm {{red_light}}Leslie{{white}}, a travelling Sales-bian from the {{olive}}Plaid Plateau{{white}}.",
    },
    ["Can I buy you a drink?"]={
      "Sorry, I have a girlfriend.",
    },
    ["Any useful info for me?"]={
      "You will need some weapons and potions if you are going to survive.",
    },
  },
  inventory = function(npc, player)
    local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
    Gamestate.stack("shopping", player, screenshot, "leslies_box")
  end,
}