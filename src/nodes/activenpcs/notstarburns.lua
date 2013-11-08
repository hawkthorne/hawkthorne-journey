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
    sounds = {
    },

    onInteract = function(activenpc, player)
        local options = {"Yes","No"}
        local callback = function(result)
            activenpc.prompt = nil
            player.freeze = false
            local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
            if result == "Yes" then
                Gamestate.stack("shopping", player, screenshot, "mysteryvendor")
            end
        end
        player.freeze = true
        activenpc.prompt = Prompt.new("Psst...need anything?",callback, options)
    end
}
