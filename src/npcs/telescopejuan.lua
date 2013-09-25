local Prompt = require 'prompt'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'

return {
    width = 48,
    height = 48,
    bb_offset_x = 0,
    bb_offset_y = 0,
    bb_width = 48,
    bb_height = 48,    
    animations = {
        default = {
            'loop',{'1-2,1'},0.60,
        },
        talking = {
            'loop',{'1,2','2,2','1,3','2,3','1,3','2,3','1,3','2,3','1,3','2,3','1,3','2,3','1,3','2,3'},0.30,
        }
    },
    sounds = {},

    items = {
        { ['text']='i am done with you' },
        { ['text']='Any useful info for me?' },
        { ['text']='Who?' },
        { ['text']='Hello!' },
    },
    responses = {
    ["Hello!"]={
        "Careful, they are here.",
    },
    ["Who?"]={
        "The aliens, I saw a QFO, but no one will believe me.",
    },
    ["Any useful info for me?"]={
        "Be careful, the QFO could attack at any time!",
        "You will need many weapons and potions.",
    },
    },
}