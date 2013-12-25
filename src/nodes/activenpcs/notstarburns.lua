local Prompt = require 'prompt'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'

return {
    width = 24,
    height = 15,
    bb_offset_x = 0,
    bb_offset_y = 0,
    bb_width = 48,
    bb_height = 48,    
    animations = {
        default = {
            'loop',{'1,1','2,1','3,1','1,1','1,1','1,1'},0.5,
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
        "These are my wares.",
    },
    ["Hello!"]={
        "Hello! I'm Leslie, a travelling Sales-bian from the Plaid Plateau.",
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