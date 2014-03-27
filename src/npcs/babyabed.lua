-- inculdes

local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

local function playSfx(npc, song)
    sound.playSfx( song )
end

return {
    width = 20,
    height = 25,   
    animations = {
        default = {
            'loop',{'1,1'},.5,
        },
        walking = {
            'loop',{'1,2','2,2'},.2,
        },

    },

    noinventory = "cool cool cool",
    nocommands = "cool cool cool",

    walking = true,
    walk_speed = 10,
    stare = true,
    minx = maxx,
    
    talk_responses = {
    },

    talk_items = {
        { ['text']='cool cool cool' },
        { ['text']='cool cool cool' },
        { ['text']='cool cool cool' },
        { ['text']='cool cool cool' },
    },
    talk_commands = {
    ["cool cool cool"]=function(npc, player)
        playSfx(npc, "coolcoolcool" )
    end,

    },
}
