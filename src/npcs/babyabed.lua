-- inculdes

local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Dialog = require 'dialog'

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

    command_items = {
    { ['text']='custom' },
    { ['text']='go home' },
    { ['text']='stay' }, 
    { ['text']='follow' }, 
    },

    

    command_commands = {
    ['follow']=function(npc, player)
        npc.walking = true
        npc.stare = true
        npc.minx = npc.maxx
    end,

    ['stay']=function(npc, player)
        npc.walking = false
        npc.stare = false
    end,
    ['go home']=function(npc, player)
        npc.walking = true
        npc.stare = false
        npc.minx = npc.maxx - (npc.props.max_walk or 48)*2
    end,
    ['custom']=function(npc, player)
        npc.walking = false
        npc.stare = false
        sound.playSfx( "dbl_beep" )
        player.freeze = true
            Dialog.new("Insufficient age!", function()
                player.freeze = false
                npc.walking = true
                Dialog.currentDialog = nil
            end)
    end,
    },
}
