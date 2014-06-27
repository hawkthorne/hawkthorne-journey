-- inculdes
local Prompt = require 'prompt'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'

return {
    width = 48,
    height = 48,  
    special_items = {'throwingtorch'},
    animations = {
        default = {
            'loop',{'1,1','2,1'},.5,
        },
        hurt = {
            'loop',{'1-4, 2'}, 0.20,
        },
        dying = {
            'once',{'3-4,1'}, 0.15,
        },
        yelling = {
            'loop',{'1-4, 3'}, 0.20,
        },
        hidden = {
            'loop',{'5, 1'}, 0.20,
        },
    },

    noinventory = "Talk to my husband to about supplies.",
    enter = function(npc, previous)
        if npc.db:get('blacksmith-dead', false) then
            npc.dead = true
            npc.state = 'hidden'
            -- Prevent the animation from playing
            npc:animation():pause()
            return
        end
        
        if previous and previous.name ~= 'town' then
            return
        end

    end,

    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='Any useful info for me?' },
        { ['text']='Anything happening here?' },
        { ['text']='Hello!' },
    },
    talk_responses = {
    ["Hello!"]={
        "Hello, I am the blacksmith's wife.",
        "You may have met my lovely daughter, Hilda.",
    },
    
    ["Anything happening here?"]={
        "I've been trying to convince my husband to build us a new home.  I keep telling him it's a terrible idea to have his workshop inside a wooden house!",
    },
    ["Any useful info for me?"]={
        "My husband is the best blacksmith around.  He can help you stock up on supplies before venturing into the woods.",
    },
    },


    update = function(dt, npc, player)
        if npc.db:get('blacksmith-dead', false) then
            npc.busy = true
            npc.state = 'hidden'
        end
    end,

}