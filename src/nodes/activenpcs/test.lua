local Prompt = require 'prompt'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'

return {
    -- normal config
    width = 32,
    height = 48,
    bb_offset_x = 0,
    bb_offset_y = 0,
    bb_width = 32,
    bb_height = 48,    
    animations = {
        default = {
            'loop',{'1,1','11,1'},.5,
        },
        walking = {
            'loop',{'1,1','2,1','3,1'},.2,
        },

    },
    sounds = {},

    -- walking config
    walking = true,
    max_walk = 48,
    walk_speed = 18,

    -- config for direction and what not
    direction = 'left',
    stare = false,

    -- Menu stuff
    items = {
        { ['text']='i am done with you' },
        { ['text']='Do you sell anything?' },
        { ['text']='Powers?' },
        { ['text']='Who are you?' },
    },
    responses = {
    ["Do you sell anything?"]={
        "These are my wares.",
    },
    ["Who are you?"]={
        "I am an NPC from the new NPC class.",
        "The plain NPCs where limited, and the activeNPCs had no menu.",
        "So he grabbed the best of both worlds and merged them, giving me new powers.",
    },
    ["Powers?"]={
        "Did you hear that? The music changed.",
        "That code was from my lua file, and allows for much more than music changes.",
    },
    },
    commands = {
    ["Powers?"] = function(activenpc, player)
        sound.playMusic('bowser')
    end,
    ["Do you sell anything?"] = function(activenpc, player)
        local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
        Gamestate.switch("shopping", player, screenshot, nil)
    end,
    }
}