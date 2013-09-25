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
            'loop',{'1-2,1'},0.20,
        },

    },
    sounds = {
    },

    onInteract = function(activenpc, player)
        local options = {"YES","NO"}
        local callback = function(result)
            activenpc.prompt = nil
            player.freeze = false
            local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
            if result == "YES" then
                Gamestate.switch("shopping", player, screenshot, "juans_smithy")
            end
        end
        player.freeze = true
        activenpc.prompt = Prompt.new("Would ya like - *hiccup* to see my - *hiccup* wares?",callback, options)
    end
}
