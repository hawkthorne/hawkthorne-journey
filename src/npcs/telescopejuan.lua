local Prompt = require 'prompt'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'

return {
    width = 48,
    height = 48,  
    animations = {
        default = {
            'loop',{'1-2,1'},0.60,
        },
        startled = {
        'once',{'1,2','2,2'},0.50,
        },
        talking = {
            'loop',{'1,3','1,3','1,3','1,3','2,3'},0.5,
        }
    },

    donotfacewhentalking = true,

    begin = function(npc, player)
        npc.state = "startled"
        Timer.add(1,function()
            npc.state = "talking"
        end)
    end,
    finish = function(npc, player)
        npc.state = "default"
    end,


    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='Any useful info for me?' },
        { ['text']='Who?' },
        { ['text']='Hello!' },
    },
    talk_responses = {
    ["Hello!"]={
        "Careful, they are here. Stay low, stay hidden!",
    },
    ["Who?"]={
        "The aliens. I saw a QFO, but no one believes me.",
    },
    ["Any useful info for me?"]={
        "Be careful, the QFO could attack at any time!",
        "You will need many weapons and potions if you are to survive its attacks.",
    },
    },
}