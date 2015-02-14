local sound = require 'vendor/TEsound'
local Timer = require('vendor/timer')
local tween = require 'vendor/tween'
local character = require 'character'
local Gamestate = require 'vendor/gamestate'
local utils = require 'utils'
require 'utils'
local anim8 = require 'vendor/anim8'
local Dialog = require 'dialog'
local prompt = require 'prompt'

return {
    width = 24,
    height = 48,  
    animations = {
        default = {
            'loop',{'1,1','1,1','1,1','1,1','1,1','1,1','1,1','1,1','1,1','1,1','1,1','1,1','1,1','1,1','1,1','1,1','1,1','4,1','5,1','4,1','5,1'},0.28,
        },
    },

    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='Any useful info for me?' },
        { ['text']='Why do you live out here?' },
        { ['text']='Talk about quests' },
    },
    talk_commands = {
        ['Talk about quests']=function(npc, player)
                npc.walking = false
                npc.stare = false
            
            if player.quest == 'To Slay an Acorn - Find the Old Hermit at Stonerspeak' then
                    local Dialogue = require 'dialog'
                                       
                    
                     script = {
"Hmmm what do you need? What? The Acorn King? He is planning on destroying the town? Well, then he must be stopped!",
"alrght good luck",
}
                    Dialogue = Dialog.create(script)
                    Dialogue:open(function()
                        Dialog.finished = true
                        player.freeze = false 
                        end)
                    

                  npc.menu:close(player)
                  player.quest = 'To Slay An Acorn' 
                  player.questParent = 'Retrieve weapon from the mines'
                  player.inventory:addItem({name='mines',type='keys'}, true)
                  player.freeze = true
                  npc.fixed = result == 'Yes'
                  --npc.walking = true
                  npc.prompt = nil
                  Timer.add(2, function() 
                    npc.fixed = false
                  end)
        else
          Dialog.new("The woods here are dangerous these days, you gotta keep your wits about you!", function()
            npc.walking = true
            npc.menu:close(player)
            end)
        end
    end,
    },
    talk_responses = {
    ["Any useful info for me?"]={
        "There's a buncha' chests hidden around these parts for some reason, check them out to see what you get!",
    },
    ["Why do you live out here?"]={
        "The nature, the trees, the wee-I mean, the water.",
        "Though it's getting dangerous these days with all them angry acorns out and about...",
    },
    },
}