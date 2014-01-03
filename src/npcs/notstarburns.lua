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
    direction = "right",
    donotfacewhentalking = true,
    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='Do I smell...meth?' },
        { ['text']='Star Burns?' },
        { ['text']='Anybody here?' },
    },
    talk_responses = {
    ["inventory"]={
        "What'cha need?",
    },
    ["Anybody here?"]={
        "...Who wants to know?",
    },
    ["Do I smell...meth?"]={
        "Only the best, courtesy of a pal from Albuquerque.",
        "It'll cost you a pretty penny, but it'll really break some enemies. Real bad.",
    },
    ["Star Burns?"]={
        "Never heard of him!",
        "My name is Alex!",
    },
    },
    inventory = function(npc, player)
        local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
        Gamestate.stack("shopping", player, screenshot, "mysteryvendor")
    end,
}