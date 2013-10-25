-- inculdes
local Prompt = require 'prompt'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'

return {
    width = 63,
    height = 66,
    animations = {
        default = {
            'loop',{'1-4,1'},0.20,
        },
        talking = {
            'loop',{'2,3','2,4'},0.20,
        }
    },
    sounds = {
        hammer = {
            state = 'default',
            position = 2,
            file = 'sword_hit',
        }
    },
    donotfacewhentalking = true,
    enter = function(npc, previous)
        if not previous.isLevel and previous~=Gamestate.get("overworld") then return end

        Timer.add(1,function()
            npc.state = 'talking'
            sound.playSfx("ibuyandsell")
            Timer.add(2.8,function()
                npc.state = 'default'
            end)
        end)
    end,
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
        "Hello, I am the blacksmith.",
        "You may have met my lovely daughter, Hilda.",
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
        Gamestate.switch("shopping", player, screenshot, npc.name)
    end,
    },
    inventory = function(npc, player)
        local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
        Gamestate.switch("shopping", player, screenshot, npc.name)
    end,
}