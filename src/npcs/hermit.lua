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
            'loop',{'1,1','2,1','3,1','3,1','1,1','2,1','3,1','3,1','1,1','2,1','3,1','3,1','1,1','2,1','3,1','3,1',
            '1,1','2,1','3,1','3,1','1,1','2,1','3,1','3,1','1,1','2,1','3,1','3,1','1,1','2,1','3,1','3,1','4,1','5,1','4,1','5,1'},0.25,
        },
    },

    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='Any useful info for me?' },
        { ['text']='Why do you live out here?' },
        { ['text']='Hello!' },
    },
    talk_commands = {
        ['Hello!']=function(npc, player)
                npc.walking = false
                npc.stare = false
            
            if player.questParent ~= 'Retrieve weapon from the mines' then
            Dialog.new("The woods here are dangerous these days, you gotta keep your wits about you!", function()
            npc.walking = true
            npc.menu:close(player)
            end)
          elseif player.questparent=='Retrieve weapon from the mines' then
            Dialog.new("Don't forget, you gotta venture inside the mines to grab the weapons room keys to access the weapos room.", function()
            npc.walking = true
            npc.menu:close(player)
            end)
          else
                    local Dialogue = require 'dialog'
                                       
                    
                     script = {
"Hmmm what do you need? What? You say you want to get into the mines?",
"The Acorn King? He is planning on destroying the town? Well, then he must be stopped!",
"So you know about the hidden weapon in the mines eh? Cornelius Hawkthorne enchanted the Acorn King to be invincible in his raging state, the weapon is the only way to slay him.",
"Long ago when the acorns showed up, the mines were closed down and locked, and you'll need a key to get inside. Fortunately, I have the key.",
"Unfortunately, it's not that simple. You're going to need a second set of keys to get inside the room where the weapon is hidden.",
"The key to the weapons room is hidden deep in the mines, you're going to have to venture inside to find it. Be careful, the mines are dangerous and full of hazards from years of disuse.",
"That was the easy part. The weapons room itself is guarded by a fearsome, indestrustible creature. Don't try fighting it, I'd advise you to sneak behind it to get inside.",
"Here's the key to the mines. Good luck my friend, I hope to see you back alive. ",
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
          end

    end,
    },
    talk_responses = {
    ["Any useful info for me?"]={
        "There's a buncha' chests hidden around these parts for some reason, check them out to see what you get!",
    },
    ["Why do you live out here?"]={
        "Honestly, I ran away from home to avoid a parking ticket for my horse but I ended up loving it out here!",
        "Though it's getting dangerous these days with all them angry acorns out and about...",
    },
    },
}