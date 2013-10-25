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
            'loop',{'1-2,1'},0.20,
        },

    },
    donotfacewhentalking = true,
    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='Do you sell anything?' },
        { ['text']='Any useful info for me?' },
        { ['text']='Hello!' },
    },
    talk_responses = {
    ["inventory"]={
        "These are my *hiccup* wares.",
    },
    ["Hello!"]={
        "Hello, *hiccup* I am Juans *hiccup* Smithy.",
    },
    ["Do you sell anything?"]={
        "These are my *hiccup* wares.",
    },
    ["Any useful info for me?"]={
        "You will need *hiccup* some weapons and potions if *hiccup* you are going to survive.",
    },
    },
    talk_commands = {
    ["Do you sell anything?"] = function(npc, player)
        local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
        Gamestate.switch("shopping", player, screenshot, "juans_smithy")
    end,
    inventory = function(npc, player)
        local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
        Gamestate.switch("shopping", player, screenshot, "juans_smithy")
    end,
    }
}