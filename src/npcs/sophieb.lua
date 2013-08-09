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
            'loop',{'1,1','1,1','1,1','1,1','1,1','1,1','1,2'},0.60,
        },
        playing = {
            'loop',{'1,1-6'},0.30,
        }
    },
    sounds = {
    },

    onInteract = function(activenpc, player)

        Timer.add(0.2,function()
            activenpc.state = 'playing'
            Timer.add(4,function()
                activenpc.state = 'default'
            end)
        end)

    end
}