local Prompt = require 'prompt'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'

return {
    width = 63,
    height = 66,
    bb_offset_x = 0,
    bb_offset_y = 17,
    bb_width = 63,
    bb_height = 49,    
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
    enter = function(activenpc)
        activenpc.state = 'talking'
        sound.playSfx("ibuyandsell")
        Timer.add(2.8,function() activenpc.state = 'default' end)
    end,
    onInteract = function(activenpc, player)
        local options = {"YES","NO"}
        local callback = function(result)
            activenpc.prompt = nil
            player.freeze = false
            local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
            if result == "YES" then
                Gamestate.switch("shopping", player, screenshot, activenpc.name)
            end
        end
        player.freeze = true
        activenpc.prompt = Prompt.new("Would you like to buy a weapon?",callback, options)
    end
}