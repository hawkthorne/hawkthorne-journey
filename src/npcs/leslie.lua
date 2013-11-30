-- inculdes
local Prompt = require 'prompt'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'

return {
    width = 48,
    height = 48,   
    animations = {
        default = {
            'loop',{'1,1','2,1','1,1','1,1','1,1','1,1'},0.5,
        },

    },
    direction = "left",
    donotfacewhentalking = true,
    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='Do you sell anything?' },
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
    ["Do you sell anything?"]={
        "These are my wares.",
    },
    ["Any useful info for me?"]={
        "You will need some weapons and potions if you are going to survive.",
    },
    },
    talk_commands = {
    ["Do you sell anything?"] = function(npc, player)
        local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
        Gamestate.stack("shopping", player, screenshot, "leslies_box")
    end,
    },
    inventory = function(npc, player)
        local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
        Gamestate.stack("shopping", player, screenshot, "leslies_box")
    end,
}