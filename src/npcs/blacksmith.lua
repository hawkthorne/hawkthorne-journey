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
        if previous and previous.name ~= 'town' then
            return
        end

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
        { ['text']='Anything happening here?' },
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
    ["Anything happening here?"]={
        "We used to have a cult leader that claimed to specialise in alchemy stay in the house next door.",
        "What was odd was that he left with nothing and there was no alchemy equipment in the house at all.",
        "We think that he was just lying in an attempt to obtain followers.",
    },
    ["Any useful info for me?"]={
        "You will need some weapons and potions if you are going to survive.",
    },
    },
    inventory = function(npc, player)
        local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
        Gamestate.stack("shopping", player, screenshot, npc.name)
    end,
}